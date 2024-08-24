//  W0 - Current position
//  W1 - Absolute position
//  W2 - Edge position
.MACRO invert_speed pos, speed
    storeFunctionsRegisters

    SUB     W1, W1, W2
    SUB     W0, W0, W1
    storeVar \pos, W0

    loadVar \speed, W0
    NEG     W0, W0
    STR     W0, [X8]

    loadFunctionsRegisters
    RET
.endmacro



// make move (change positions to new frame)
move:
    storeFunctionsRegisters

move_userPlatform:
    loadVar userPlatformDirection, W0
    MOV     W1, 0
    storeVar userPlatformDirection, W1
    CMP     W0, W1
    B.eq    move_opponentPlatform

    loadVar platformSpeed, W1
    MUL     W0, W0, W1
    loadVar userPlatformY, W1
    ADD     W0, W0, W1

min_userPlatformY:
    loadVar userPlatformMinY, W1
    CMP     W0, W1
    B.gt    max_userPlatformY
    MOV     W0, W1

max_userPlatformY:
    loadVar userPlatformMaxY, W1
    CMP     W0, W1
    B.lt    store_userPlatformY
    MOV     W0, W1

store_userPlatformY:
    storeVar userPlatformY, W0

move_opponentPlatform:
    loadVar opponentPlatformDirection, W0
    MOV     W1, 0
    storeVar opponentPlatformDirection, W1
    CMP     W0, W1
    B.eq    move_ball

    loadVar platformSpeed, W1
    MUL     W0, W0, W1
    loadVar opponentPlatformY, W1
    ADD     W0, W0, W1

min_opponentPlatformY:
    loadVar opponentPlatformMinY, W1
    CMP     W0, W1
    B.gt    max_opponentPlatformY
    MOV     W0, W1

max_opponentPlatformY:
    loadVar opponentPlatformMaxY, W1
    CMP     W0, W1
    B.lt    store_opponentPlatformY
    MOV     W0, W1

store_opponentPlatformY:
    storeVar opponentPlatformY, W0

move_ball:
    loadVar ballSpeedX, W1
    loadVar ballX, W0
    ADD     W0, W0, W1
    STR     W0, [X8]

    loadVar ballSpeedY, W1
    loadVar ballY, W0
    ADD     W0, W0, W1
    STR     W0, [X8]

comparison_ballX:
    loadVar ballX, W0
    loadVar ballW, W1
    LDR     W1, [X8]
    ADD     W1, W0, W1
    
cmp_window_w_end:
    MOV     W2, WINDOW_W
    CMP     W2, W1
    B.gt    cmp_window_w_start

incr_user_score:
    MOV     X26, X0
    MOV     X27, X1
    MOV     X28, X2

    incrVar userScore, W0
    MOV     W1, 58
    CMP     W0, W1
    B.ne    end_incr_user_score
    BL      reset_values
    B       move_end
    
end_incr_user_score:   
    BL      update_window_title

    MOV     X0, X26
    MOV     X1, X27
    MOV     X2, X28

    B       invert_speed_x

cmp_window_w_start:
    MOV     W2, 0
    CMP     W1, W2
    B.gt    check_collision_with_user_platform

incr_opponent_score:
    MOV     X26, X0
    MOV     X27, X1
    MOV     X28, X2

    incrVar opponentScore, W0
    MOV     W1, 58
    CMP     W0, W1
    B.ne    end_incr_opponent_score
    BL      reset_values
    B       move_end

end_incr_opponent_score: 
    BL      update_window_title

    MOV     X0, X26
    MOV     X1, X27
    MOV     X2, X28

    B       invert_speed_x

check_collision_with_user_platform:
    adrpVar ballX, X0
    adrpVar userPlatformX, X1
    BL      _SDL_HasIntersection
    MOV     W1, 1
    CMP     W0, W1
    loadVar ballX, W0
    MOV     W1, W0
    loadVar userPlatformW, W2
    B.eq    invert_speed_x

check_collision_with_opponent_platform:
    adrpVar ballX, X0
    adrpVar opponentPlatformX, X1
    BL      _SDL_HasIntersection
    MOV     X1, 0
    CMP     X0, X1
    loadVar ballX, W0
    loadVar ballW, W1
    ADD     W1, W1, W0
    loadVar opponentPlatformX, W2
    B.eq    comparison_ballY

invert_speed_x:
    BL      _invert_speed_x_function

comparison_ballY:
    loadVar ballY, W0
    loadVar ballH, W1
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


_invert_speed_x_function:
    invert_speed ballX, ballSpeedX

_invert_speed_y_function:
    invert_speed ballY, ballSpeedY
