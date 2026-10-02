.386
BUFER_MAX_LEN EQU 20

INPUT_CHAR_ECHO_CODE EQU 01
OUTPUT_CHAR_CODE EQU 02

INPUT_STR_CODE EQU 0Ah
OUTPUT_STR_CODE EQU 09

NEW_LINE EQU 13
START_LEN EQU 10
END_STRING EQU '$'

HEX_SHIFT EQU 4


; Общий сегмент с числом
NumSeg SEGMENT USE16 COMMON 'Number'
    number label word
NumSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME ES:NumSeg, CS:CodeSeg

output_sign_short proc far
    push bx
    push cx
    push dx

    mov ax, es:[number]
    xor ah, ah

    ; прочитали знак
    test al, 10000000b
    jz no_neg
    
    ; отрицательное число
    neg al
    mov ah, 0

    xor ah, ah
    mov dl, '-'
    push ax
    mov ah, OUTPUT_CHAR_CODE
    int 21h
    pop ax

no_neg:
    xor ah, ah
    xor cx, cx
    mov dh, 10
    ; конвертация в 10 с/с
    convert_loop:
        inc cx
        div dh
        push ax
        xor ah, ah
        
        test al, al
        jnz convert_loop
    
    ; вывод 10-х чисел
    print_loop:
        pop ax
        mov dl, '0'
        add dl, ah

        push ax
        mov ah, OUTPUT_CHAR_CODE
        int 21h
        pop ax

        loop print_loop 
        

    pop dx
    pop cx
    pop bx
    retf

output_sign_short endp

CodeSeg ENDS
END
