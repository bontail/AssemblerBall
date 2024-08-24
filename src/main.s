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
SDL_SCANCODE_SPACE = 44

WINDOW_W = 1100
WINDOW_H = 700

BALL_W = 10
BALL_H = 10
BALL_X = (WINDOW_W - BALL_W) / 2
BALL_Y = (WINDOW_H - BALL_H) / 2
BALL_SPEED_X = 7
BALL_SPEED_Y = 7

PLATFORM_DEFAULT_W = 20
PLATFORM_DEFAULT_H = 100
PLATFORM_DEFAULT_Y = (WINDOW_H - PLATFORM_DEFAULT_H) / 2

USER_X = 0
USER_MIN_Y = 0
USER_MAX_Y = WINDOW_H - PLATFORM_DEFAULT_H

OPPONENT_X = WINDOW_W - PLATFORM_DEFAULT_W
OPPONENT_MIN_Y = 0
OPPONENT_MAX_Y = WINDOW_H - PLATFORM_DEFAULT_H

STATE_MENU = 0
STATE_GAME = 1

AF_INET = 2
SOCK_DGRAM = 2



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


.MACRO incrVar, var, reg
    loadVar \var, \reg
    ADD \reg, \reg, 1
    storeVar \var, \reg
.endmacro



#include "render.s"
#include "move.s"


// print SDL error
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


// set windowTitle with format "{userScore} AssemblerBall {opponentScore}\0"
update_window_title_text:
    storeFunctionsRegisters

    loadVar userScore, W0
    MOV     X1, 32 // space
    LSL     X1, X1, 8
    ADD     X0, X0, X1
    storeVar windowTitle, X0
    loadVar textWindowTitleFirst, X0
    adrpVar windowTitle, X8
    ADD     X8, X8, 2
    STR     X0, [X8]

    MOV     X0, 32 // space
    loadVar opponentScore, W1
    LSL     X1, X1, 8
    ADD     X0, X0, X1
    LSL     X0, X0, 40
    loadVar textWindowTitleSecond, X1
    LSL     X1, X1, 24
    LSR     X1, X1, 24
    ADD     X0, X0, X1
    adrpVar windowTitle, X8
    ADD     X8, X8, 10
    STR     X0, [X8]

    loadFunctionsRegisters
    RET


// call update_window_title_text
// call _SDL_SetWindowTitle
update_window_title:
    storeFunctionsRegisters

    BL      update_window_title_text

    loadVar window, X0
    adrpVar windowTitle, X1
    BL      _SDL_SetWindowTitle

    loadFunctionsRegisters
    RET


// set default value to game vars
reset_values:
    storeFunctionsRegisters

    MOV     W0, STATE_MENU
    storeVar state, W0

    MOV     W0, PLATFORM_DEFAULT_Y
    storeVar opponentPlatformY, W0
    storeVar userPlatformY, W0

    MOV     W0, 48
    storeVar userScore, W0
    storeVar opponentScore, W0

    MOV     W0, BALL_SPEED_X
    storeVar ballSpeedX, W0

    MOV     W0, BALL_SPEED_Y
    storeVar ballSpeedY, W0

    MOV     W0, BALL_X
    storeVar ballX, W0

    MOV     W0, BALL_Y
    storeVar ballY, W0

    MOV     W0, 0
    storeVar userPlatformDirection, W0
    storeVar opponentPlatformDirection, W0

    BL      update_window_title

    loadFunctionsRegisters
    RET


// start function with game loop
_main:
    storeFunctionsRegisters

// init library and global vars
init:
    MOV     X0, 0
    BL      _time
    BL      _srand

// _SDL_Init
    MOV     X0, SDL_INIT_EVERYTHING
    BL      _SDL_Init
    CMP     X0, 0
    B.ne    print_error

// _SDL_CreateWindow
    BL      update_window_title_text
    adrpVar windowTitle, X0
    MOV     X1, SDL_WINDOWPOS_CENTERED
    MOV     X2, SDL_WINDOWPOS_CENTERED
    MOV     X3, WINDOW_W
    MOV     X4, WINDOW_H
    MOV     X5, SDL_WINDOW_SHOWN
    BL      _SDL_CreateWindow
    storeVar window, X0
    CMP     X0, 0
    B.eq    print_error

// _SDL_CreateRenderer
    MOV     X1, -1
    MOV     X2, SDL_RENDERER_PRESENTVSYNC
    BL      _SDL_CreateRenderer
    storeVar renderer, X0
    CMP     X0, 0
    B.eq    print_error

    BL      reset_values

    SUB     SP, SP, SDL_Event_stackzie

init_socket:
// socket
    MOV     X0, AF_INET
    MOV     X1, SOCK_DGRAM
    MOV     X2, 0
    BL      _socket
    MOV     X1, 0
    CMP     X0, X1
    B.lt    print_error
    storeVar socketRefClient, W0

// socket
    MOV     X0, AF_INET
    MOV     X1, SOCK_DGRAM
    MOV     X2, 0
    BL      _socket
    MOV     X1, 0
    CMP     X0, X1
    B.lt    print_error
    storeVar socketRefServer, W0

// bind
    adrpVar socketServerAddress, X1
    loadVar socketAddressLen, W2
    BL      _bind
    MOV     X1, 0
    CMP     X0, X1
    B.lt    print_error

// main game loop
while_isRunning:
    MOV     X0, SP
    BL      _SDL_PollEvent
    CMP     X0, 0
    B.eq    swith_states

switch_events:
    LDR     W0, [SP]

cmp_quit_event:
    MOV     W1, SDL_QUIT
    CMP     W0, W1
    B.ne    cmp_keydown_event

quit_app:
    MOV     X0, 0
    storeVar isRunning, X0
    B swith_states

cmp_keydown_event:
    MOV     W1, SDL_KEYDOWN
    CMP     W0, W1
    B.ne    swith_states

switch_keydowns:
    LDR     W0, [SP, 16]

cmp_user_up:
    MOV     W1, SDL_SCANCODE_W
    CMP     W0, W1
    B.ne    cmp_user_down
    MOV     W1, -1
    storeVar userPlatformDirection, W1

cmp_user_down:
    MOV     W1, SDL_SCANCODE_S
    CMP     W0, W1
    B.ne    cmp_change_state_to_game
    MOV     W1, 1
    storeVar userPlatformDirection, W1

cmp_change_state_to_game:
    MOV     W1, SDL_SCANCODE_SPACE
    CMP     W0, W1
    B.ne    swith_states
    MOV     W1, STATE_GAME
    storeVar state, W1

swith_states:
    MOV     W0, STATE_MENU
    loadVar state, W1
    CMP     W0, W1
    B.ne    cmp_state_find
    BL      render_menu

cmp_state_find:
    MOV     W0, STATE_GAME
    loadVar state, W1
    CMP     W0, W1
    B.ne    end_while_isRunning

send_direction:
    loadVar socketRefClient, W0
    adrpVar userPlatformDirection, X1
    MOV     X2, 4 // buffer size
    MOV     X3, 0
    adrpVar socketClientAddress, X4
    loadVar socketAddressLen, W5
    BL      _sendto

rec_direction:
    loadVar socketRefServer, W0
    adrpVar opponentPlatformDirection, X1
    MOV     X2, 4 // buffer size
    MOV     X3, 0
    adrpVar socketServerAddress, X4
    adrpVar socketAddressLen, X5
    BL      _recvfrom

make_new_frame:
    BL      render_game
    BL      move

end_while_isRunning:
    loadVar isRunning, W0
    CMP     W0, 1
    B.eq    while_isRunning

end_main:
    loadVar renderer, X0
    BL      _SDL_DestroyRenderer

    loadVar window, X0
    BL      _SDL_DestroyWindow

    BL      _SDL_Quit

    ADD     SP, SP, SDL_Event_stackzie

    loadFunctionsRegisters
    RET




.text
errorMessage: .ascii  "SDL Error: %d\n"
textWindowTitleFirst: .ascii "Assemble"
textWindowTitleSecond: .ascii "rBall"


.data
windowTitle: .space 18


window: .quad 0
renderer: .quad 0


ballX: .word BALL_X
ballY: .word BALL_Y
ballW: .word BALL_W
ballH: .word BALL_H

ballSpeedX: .word 7
ballSpeedY: .word 7


userPlatformX: .word USER_X
userPlatformY: .word PLATFORM_DEFAULT_Y
userPlatformW: .word PLATFORM_DEFAULT_W
userPlatformH: .word PLATFORM_DEFAULT_H

userScore: .word 48 // 48 == '1'
userPlatformDirection: .word 0 // 1 = DOWN,  -1 = UP, 0 = NULL
userPlatformMinY: .word USER_MIN_Y
userPlatformMaxY: .word USER_MAX_Y


opponentPlatformX: .word OPPONENT_X
opponentPlatformY: .word PLATFORM_DEFAULT_Y
opponentPlatformW: .word PLATFORM_DEFAULT_W
opponentPlatformH: .word PLATFORM_DEFAULT_H

opponentScore: .word 48
opponentPlatformDirection: .word 0 // 1 = DOWN,  -1 = UP, 0 = NULL
opponentPlatformMinY: .word OPPONENT_MIN_Y
opponentPlatformMaxY: .word OPPONENT_MAX_Y


platformSpeed: .word 20
isRunning: .word 1
state: .word STATE_MENU


socketAddressLen: .word 16

socketRefServer: .word 0
socketServerAddress: .byte 0
socketServerAddressPart2: .byte 2
socketServerAddressPart3: .byte 173
socketServerAddressPart4: .byte 156
socketServerAddressPart5: .word 0
socketServerAddressPart6: .quad 0


socketRefClient: .word 0
socketClientAddress: .byte 0
socketServerClientPart2: .byte 2
socketServerClientPart3: .byte 130
socketServerClientPart4: .byte 53
socketServerClientPart5: .byte 127
socketServerClientPart6: .short 0
socketServerClientPart7: .byte 1
socketServerClientPart8: .quad 0