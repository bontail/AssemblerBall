.MACRO drawPoint, x, y
    loadVar renderer, X0
    MOV     X1, \x
    MOV     X2, \y
    BL      _SDL_RenderDrawPoint
.endmacro



// render ball, g_userPlatform, g_opponentPlatform
render_game:
    storeFunctionsRegisters

    loadVar renderer, X0
    MOV     X1, 0
    MOV     X2, 0
    MOV     X3, 0
    MOV     X4, 0
    BL      _SDL_SetRenderDrawColor

    loadVar renderer, X0
    BL      _SDL_RenderClear

    loadVar renderer, X0
    MOV     X1, 255
    MOV     X2, 255
    MOV     X3, 255
    MOV     X4, 0
    BL      _SDL_SetRenderDrawColor

render_ball:
    loadVar renderer, X0
    adrpVar ballX, X1
    BL      _SDL_RenderFillRect

render_user_platform:
    loadVar renderer, X0
    adrpVar userPlatformX, X1
    BL      _SDL_RenderFillRect

render_opponent_platform:
    loadVar renderer, X0
    adrpVar opponentPlatformX, X1
    BL      _SDL_RenderFillRect

render_game_end:
    loadVar renderer, X0
    BL      _SDL_RenderPresent

    loadFunctionsRegisters
    RET



// render 'M' char
render_menu:
    storeFunctionsRegisters

    loadVar renderer, X0
    MOV     X1, 0
    MOV     X2, 0
    MOV     X3, 0
    MOV     X4, 0
    BL      _SDL_SetRenderDrawColor

    loadVar renderer, X0
    BL      _SDL_RenderClear

    loadVar renderer, X0
    MOV     X1, 255
    MOV     X2, 255
    MOV     X3, 255
    MOV     X4, 0
    BL      _SDL_SetRenderDrawColor

render_menu_text:
    #include "menu_text.s"

render_menu_end:
    loadVar renderer, X0
    BL      _SDL_RenderPresent

    loadFunctionsRegisters
    RET
