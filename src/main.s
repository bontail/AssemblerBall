.global _main
.align 2



SDL_INIT_EVERYTHING = 62001
SDL_WINDOWPOS_CENTERED = 805240832
SDL_WINDOW_SHOWN = 4
SDL_RENDERER_PRESENTVSYNC = 4
SDL_Event_size = 56
SDL_Event_stackzie = 64
SDL_QUIT = 256
SDL_KEYDOWN = 768
SDL_SCANCODE_W = 26
SDL_SCANCODE_S = 22



WINDOW_W = 800
WINDOW_H = 600

BALL_W = 10
BALL_H = 10
BALL_X = (WINDOW_W - BALL_W) / 2
BALL_Y = (WINDOW_H - BALL_H) / 2

USER_W = 20
USER_H = 100
USER_X = 0
USER_Y = 0
USER_MIN_Y = 0
USER_MAX_Y = WINDOW_H - USER_H

COMPUTER_W = 20
COMPUTER_H = 100
COMPUTER_X = WINDOW_W - COMPUTER_W
COMPUTER_Y = (WINDOW_H - COMPUTER_H) / 2
COMPUTER_MIN_Y = 0
COMPUTER_MAX_Y = WINDOW_H - COMPUTER_H



.MACRO storeFunctionsRegisters
    SUB     SP, SP, 16
    STP     FP, LR, [SP]
.endmacro


.MACRO loadFunctionsRegisters
    LDP     FP, LR, [SP]
    ADD     SP, SP, 16
.endmacro


.MACRO adrpVar, var, reg
    ADRP    \reg, \var@PAGE
    ADD     \reg, \reg, \var@PAGEOFF
.endmacro


.MACRO adrpVarCommand, var, reg, command
    adrpVar \var, X8
    \command     \reg, [X8]
.endmacro


.MACRO storeVar, var, reg
    adrpVarCommand \var, \reg, STR
.endmacro


.MACRO loadVar, var, reg
    adrpVarCommand \var, \reg, LDR
.endmacro



quit_app:
    MOV     X0, 0
    storeVar g_isRunning, X0
    B end_while_isRunning


switch_keydowns:
    LDR     W0, [SP, 16]
    
    MOV     W1, SDL_SCANCODE_W
    CMP     W0, W1
    B.eq    set_direction_up

    MOV     W1, SDL_SCANCODE_S
    CMP     W0, W1
    B.eq    set_direction_down

    B end_while_isRunning

set_direction_up:
    MOV     W7, -1
    storeVar g_userPlatformDirection, W7
    B end_while_isRunning

set_direction_down:
    MOV     W1, 1
    storeVar g_userPlatformDirection, W1
    B end_while_isRunning



_main: 
    storeFunctionsRegisters
    
    BL      init
    SUB     SP, SP, SDL_Event_stackzie

while_isRunning:
    MOV     X0, SP
    BL      _SDL_PollEvent
    CMP     X0, 0
    B.eq    end_while_isRunning
    LDR     W0, [SP]

    MOV     W1, SDL_QUIT
    CMP     W0, W1
    B.eq    quit_app

    MOV     W1, SDL_KEYDOWN
    CMP     W0, W1
    B.eq    switch_keydowns

end_while_isRunning:
    BL      render
    BL      move

    loadVar g_isRunning, X0
    CMP     X0, 1      
    B.eq    while_isRunning  

    loadVar g_renderer, X0
    BL      _SDL_DestroyRenderer

    loadVar g_window, X0
    BL      _SDL_DestroyWindow

    BL      _SDL_Quit

    ADD     SP, SP, SDL_Event_stackzie

    loadFunctionsRegisters
    RET



init:
    storeFunctionsRegisters

    MOV     X0, 0
    BL      _time
    BL      _srand

    MOV     X0, SDL_INIT_EVERYTHING
    BL      _SDL_Init
    CMP     X0, 0
    B.ne    print_error

    ADR     X0, windowTitle
    MOV     X1, SDL_WINDOWPOS_CENTERED
    MOV     X2, SDL_WINDOWPOS_CENTERED
    MOV     X3, WINDOW_W
    MOV     X4, WINDOW_H
    MOV     X5, SDL_WINDOW_SHOWN
    BL      _SDL_CreateWindow
    storeVar g_window, X0
    CMP     X0, 0
    B.eq    print_error

    MOV     X1, -1
    MOV     X2, SDL_RENDERER_PRESENTVSYNC
    BL      _SDL_CreateRenderer
    storeVar g_renderer, X0
    CMP     X0, 0
    B.eq    print_error

    loadFunctionsRegisters
    RET



print_error:
    BL      _SDL_GetError
    SUB     SP, SP, 16
    STR     X0, [SP]
    adrpVar errorMessage, X0
    BL      _printf

    // exit app
    mov     X0, 1
    mov     X16, 1
    svc     0           



render:
    storeFunctionsRegisters

    loadVar g_renderer, X0
    MOV     X1, 0
    MOV     X2, 0
    MOV     X3, 0
    MOV     X4, 0
    BL      _SDL_SetRenderDrawColor

    loadVar g_renderer, X0
    BL      _SDL_RenderClear

render_ball:
    loadVar g_renderer, X0
    MOV     X1, 255
    MOV     X2, 255
    MOV     X3, 255
    MOV     X4, 0
    BL      _SDL_SetRenderDrawColor

    loadVar g_renderer, X0
    adrpVar g_ballX, X1
    BL      _SDL_RenderFillRect

render_user_platform:
    loadVar g_renderer, X0
    adrpVar g_userPlatformX, X1
    BL      _SDL_RenderFillRect

render_computer_platform:
    loadVar g_renderer, X0
    adrpVar g_computerPlatformX, X1
    BL      _SDL_RenderFillRect

render_end:
    loadVar g_renderer, X0
    BL      _SDL_RenderPresent

    loadFunctionsRegisters
    RET



move:
    storeFunctionsRegisters

move_userPlatform:
    loadVar g_userPlatformDirection, W0
    MOV     W1, 0
    storeVar g_userPlatformDirection, W1
    CMP     W0, W1
    B.eq    move_computerPlatform

    loadVar g_platformSpeed, W1
    MUL     W0, W0, W1
    loadVar g_userPlatformY, W1
    ADD     W0, W0, W1

min_userPlatformY:
    loadVar g_userPlatformMinY, W1
    CMP     W0, W1
    B.gt    max_userPlatformY
    MOV     W0, W1

max_userPlatformY:
    loadVar g_userPlatformMaxY, W1
    CMP     W0, W1
    B.lt    store_userPlatformY
    MOV     W0, W1

store_userPlatformY:
    storeVar g_userPlatformY, W0

move_computerPlatform:
    BL      _rand
    MOV     W1, 3
    AND     W0, W0, W1
    SUB     W0, W0, 2
    loadVar g_platformSpeed, W1
    MUL     W0, W0, W1
    loadVar g_computerPlatformY, W1
    ADD     W0, W0, W1

min_computerPlatformY:
    loadVar g_computerPlatformMinY, W1
    CMP     W0, W1
    B.gt    max_computerPlatformY
    MOV     W0, W1

max_computerPlatformY:
    loadVar g_computerPlatformMaxY, W1
    CMP     W0, W1
    B.lt    store_computerPlatformY
    MOV     W0, W1

store_computerPlatformY:
    MOV     W3, W0
    BL      _rand
    MOV     W1, 667
    AND     W0, W0, W1
    MOV     W1, 10
    CMP     W0, W1
    B.ge    move_ball
    storeVar g_computerPlatformY, W3

move_ball:
    loadVar g_ballSpeedX, W1
    loadVar g_ballX, W0
    ADD     W0, W0, W1
    STR     W0, [X8]

    loadVar g_ballSpeedY, W1
    loadVar g_ballY, W0
    ADD     W0, W0, W1
    STR     W0, [X8]

comparison_ballX:
    loadVar g_ballX, W0
    loadVar g_ballW, W1
    LDR     W1, [X8]
    ADD     W1, W0, W1
    
    MOV     W2, WINDOW_W
    CMP     W2, W1
    B.le    invert_speed_x

    MOV     W2, 0
    CMP     W1, W2
    B.le    invert_speed_x

check_collision_with_user_platform:
    adrpVar g_ballX, X0
    adrpVar g_userPlatformX, X1
    BL      _SDL_HasIntersection
    MOV     W1, 1
    CMP     W0, W1
    loadVar g_ballX, W0
    MOV     W1, W0
    loadVar g_userPlatformW, W2
    B.eq    invert_speed_x

check_collision_with_computer_platform:
    adrpVar g_ballX, X0
    adrpVar g_computerPlatformX, X1
    BL      _SDL_HasIntersection
    MOV     X1, 0
    CMP     X0, X1
    loadVar g_ballX, W0
    loadVar g_ballW, W1
    ADD     W1, W1, W0
    loadVar g_computerPlatformX, W2
    B.eq    comparison_ballY

invert_speed_x:
    BL      _invert_speed_x_function

comparison_ballY:
    loadVar g_ballY, W0
    loadVar g_ballH, W1
    ADD     W1, W0, W1

    MOV     W2, WINDOW_H
    CMP     W2, W1
    B.le    invert_speed_y

    MOV     W2, 0
    CMP     W2, W1
    B.lt    move_end

invert_speed_y:    
    BL      _invert_speed_y_function

move_end:
    loadFunctionsRegisters
    RET



.MACRO invert_speed pos, speed
//  W0 - Current position
//  W1 - Absolute position
//  W2 - Edge position
    SUB     W1, W1, W2
    SUB     W0, W0, W1
    storeVar \pos, W0

    loadVar \speed, W0
    NEG     W0, W0
    STR     W0, [X8]
    RET
.endmacro

_invert_speed_x_function:
    invert_speed g_ballX, g_ballSpeedX

_invert_speed_y_function:
    invert_speed g_ballY, g_ballSpeedY



.text   
errorMessage: .ascii  "SDL Error: %s\n"
windowTitle: .ascii "AssemblerBall"



.data
g_window: .quad 0
g_renderer: .quad 0

g_ballX: .word BALL_X
g_ballY: .word BALL_Y
g_ballW: .word BALL_W
g_ballH: .word BALL_H
g_ballSpeedX: .word 7
g_ballSpeedY: .word 7

g_userPlatformX: .word USER_X
g_userPlatformY: .word USER_Y
g_userPlatformW: .word USER_W
g_userPlatformH: .word USER_H
g_userPlatformDirection: .word 0 // 1 = DOWN,  -1 = UP
g_userPlatformMinY: .word USER_MIN_Y
g_userPlatformMaxY: .word USER_MAX_Y

g_computerPlatformX: .word COMPUTER_X
g_computerPlatformY: .word COMPUTER_Y
g_computerPlatformW: .word COMPUTER_W
g_computerPlatformH: .word COMPUTER_H
g_computerPlatformDirection: .word 0 // 1 = DOWN,  -1 = UP
g_computerPlatformMinY: .word COMPUTER_MIN_Y
g_computerPlatformMaxY: .word COMPUTER_MAX_Y

g_platformSpeed: .word 20
g_isRunning: .word 1