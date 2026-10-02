DIVIDER_NUM EQU 3

NEW_LINE_CHR EQU 10
START_LINE_CHR EQU 13

OUTPUT_CHR_CODE EQU 02
OUTPUT_STR_CODE EQU 09
INPUT_CHR_CODE  EQU 01

DIGIT_SYMBOL_SHIFT EQU '0'



STK SEGMENT PARA STACK 'STACK'
    db 50 DUP(0)
STK ENDS

SIZE_DEFAULT EQU 9
DATA SEGMENT PARA 'DATA'
    row db SIZE_DEFAULT
    col db SIZE_DEFAULT

    arr db SIZE_DEFAULT * SIZE_DEFAULT DUP(?)

    row_input_msg db 'Input row count: ', '$'
    col_input_msg db 'Input col count: ', '$'
DATA ENDS

CODE SEGMENT PARA 'CODE'
ASSUME CS:CODE, DS:DATA

output_row proc
    push cx
    mov cl, [col]
    ;mov cl, SIZE_DEFAULT
    mov ch, 0

    mov ah, OUTPUT_CHR_CODE
    elem_print_loop:
        mov dl, [si]
        add dl, DIGIT_SYMBOL_SHIFT
        int 21h
        mov dl, ' '
        int 21h

        inc si
        loop elem_print_loop
    
    call output_new_line

    pop cx
    ret

output_row endp

output_mtr proc
    mov cl, [row]
    ;mov cl, SIZE_DEFAULT
    mov ch, 0

    mov si, offset arr
    row_print_loop:
        call output_row

        add si, SIZE_DEFAULT
        mov ax, 0
        mov al, [col]
        sub si, ax

        loop row_print_loop
    ret    
output_mtr endp

; Деление всех чисел матрицы на установленное число
div_mtr proc
    mov cl, [row]
    ;mov cl, SIZE_DEFAULT
    mov ch, 0

    mov si, offset arr
    loop2:
        call div_row

        add si, SIZE_DEFAULT
        mov ax, 0
        mov al, [col]
        sub si, ax

        loop loop2
    ret    
div_mtr endp
div_row proc
    push cx
    mov cl, [col]
    mov ch, 0

    elem_div_loop:
        mov ah, 0
        mov al, [si]
        mov bl, DIVIDER_NUM
        div bl
        mov [si], ah

        inc si
        loop elem_div_loop

    pop cx
    ret
div_row endp

input_mtr_size proc
    ; Ввод количества строк
    mov ah, OUTPUT_STR_CODE
    mov dx, offset row_input_msg
    int 21h
    
    mov ah, INPUT_CHR_CODE
    int 21h
    sub al, DIGIT_SYMBOL_SHIFT
    mov row, al

    call output_new_line

    ; Ввод количества колонок
    mov ah, OUTPUT_STR_CODE
    mov dx, offset col_input_msg
    int 21h

    mov ah, INPUT_CHR_CODE
    int 21h
    sub al, DIGIT_SYMBOL_SHIFT
    mov col, al

    call output_new_line

    ret
input_mtr_size endp

input_mtr proc
    mov cl, [row]
    mov ch, 0

    row_input_loop:
        call input_row_mtr

        add si, SIZE_DEFAULT
        mov ax, 0
        mov al, [col]
        sub si, ax

        loop row_input_loop

    ret
input_mtr endp

input_row_mtr proc
    push cx

    mov cl, [col]
    mov ch, 0
    
    input_elem_loop:
        mov ah, 01
        int 21h
        sub al, DIGIT_SYMBOL_SHIFT
        mov [si], al

        call output_new_line

        inc si
        loop input_elem_loop
    pop cx
    ret
input_row_mtr endp

output_new_line proc
    mov ah, 02
    mov dl, NEW_LINE_CHR
    int 21h
    mov dl, START_LINE_CHR
    int 21h

    ret
output_new_line endp


main:
    mov ax, DATA
    mov ds, ax

    call input_mtr_size
    
    mov si, offset arr
    call input_mtr
    call output_new_line

    ; Вывод исходной матрицы
    mov si, offset arr
    call output_mtr
    call output_new_line

    ; Замена всех цифр на остатот от деления
    mov si, offset arr
    call div_mtr
    
    ; Вывод полученной матрицы
    mov si, offset arr
    call output_mtr
    
    mov ax, 4C00h
    int 21h

CODE ENDS
END main

