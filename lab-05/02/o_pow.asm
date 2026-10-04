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

min_degree proc far
    push bx
    push cx
    push dx

    mov ax, es:[number]

    ; получение минимальной степени 2-ки
    bsr dx, ax
    inc dl
    mov ax, dx

    ; вывод результата
    xor cx, cx
    mov bl, 10

    test dx, dx
    jz print_zero

    ; ковертация числа
    convert_loop:
        inc cx
        div bl
        push ax
        xor ah, ah
        
        test al, al
        jnz convert_loop

    ; вывод числа
    print_loop:
        pop ax
        mov dl, '0'
        add dl, ah

        mov ah, OUTPUT_CHAR_CODE
        int 21h
        loop print_loop
    jmp exit

    print_zero:
        mov dl, '1'
        mov ah, OUTPUT_CHAR_CODE
        int 21h
        
exit:
    pop dx
    pop cx
    pop bx
    retf

min_degree endp

CodeSeg ENDS
END
