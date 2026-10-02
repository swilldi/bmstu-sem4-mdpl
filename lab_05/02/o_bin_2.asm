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
ASSUME DS:NumSeg, CS:CodeSeg


output_unsign_binary proc
    push bx
    push cx

    mov bx, es:[number]
    mov cx, 16

    print_loop:
        shl bx, 1
        jc print_one

        mov ah, OUTPUT_CHAR_CODE
        mov dl, '0'
        int 21h
        jmp bit_done

    print_one:
        mov ah, OUTPUT_CHAR_CODE
        mov dl, '1'
        int 21h

    bit_done:
        loop print_loop

    pop cx
    pop bx
    retf

output_unsign_binary endp

CodeSeg ENDS
END
