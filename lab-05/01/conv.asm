.386
include const.inc

PUBLIC input_num

EXTRN buf_max:byte
EXTRN buf_cur:byte
EXTRN buf_str:byte

NumbersSeg SEGMENT USE16 COMMON 'Numbers'
    num dw ?
NumbersSeg ENDS

DataSeg SEGMENT USE16 PUBLIC 'Data'
DataSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME CS:CodeSeg, DS:DataSeg

input_num proc far
    mov ax, DataSeg
    mov ds, ax

    ; ввод строки
    mov dx, offset buf_max
    mov ah, INPUT_STRING
    int 21h

    ; новая строка
    mov ah, OUTPUT_CHAR
    mov dl, NEW_LINE_CODE
    int 21h
    mov dl, START_LINE_CODE
    int 21h

    ; ставим '$' в конец для вывода
    mov bx, offset buf_str
    mov al, [buf_cur]
    xor ah, ah
    mov di, ax
    mov byte ptr [bx + di], '$'

    ; конвертируем строку в число
    call near ptr str_to_num

    retf
input_num endp

; --- внутренняя процедура конвертации ---
str_to_num proc near
    mov ax, NumbersSeg
    mov es, ax

    mov cl, [buf_cur]
    xor ch, ch
    mov si, offset buf_str

    xor dx, dx                   ; флаг знака = 0
    cmp byte ptr [si], '-'
    jne conv_start
    mov dx, 1
    inc si
    dec cx

conv_start:
    xor ax, ax

conv_loop:
    shl ax, 4
    mov bl, [si]
    inc si

    cmp bl, '9'
    jbe is_digit
    cmp bl, 'F'
    jbe is_upper
    jmp is_lower

is_digit:
    sub bl, '0'
    xor bh, bh
    add ax, bx
    loop conv_loop
    jmp conv_done

is_upper:
    sub bl, 'A'
    xor bh, bh
    add ax, bx
    add ax, 10
    loop conv_loop
    jmp conv_done

is_lower:
    sub bl, 'a'
    xor bh, bh
    add ax, bx
    add ax, 10
    loop conv_loop

conv_done:
    cmp dx, 1
    jne no_neg
    neg ax
no_neg:
    mov es:[0], ax       ; num = ax (биты одинаковы для знакового/беззнакового)
    ret
str_to_num endp

CodeSeg ENDS
END
