.386
include const.inc

PUBLIC output_short

NumbersSeg SEGMENT USE16 COMMON 'Numbers'
    num dw ?
NumbersSeg ENDS

DataSeg SEGMENT USE16 PUBLIC 'Data'
    msg_short db "Usechennoe do 8 bit (znakovoe, dec): $"
    msg_nl    db 0Dh, 0Ah, '$'
    msg_minus db '-', '$'
DataSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME CS:CodeSeg, DS:DataSeg

output_short proc far
    mov ax, DataSeg
    mov ds, ax

    mov ah, OUTPUT_STRING
    mov dx, offset msg_short
    int 21h

    ; загружаем snum (byte, знаковое)
    mov ax, NumbersSeg
    mov es, ax
    mov al, byte ptr es:[0]  ; младший байт num (усечение до 8 бит)
    cbw                  ; расширяем AL до AX со знаком

    ; если отрицательное — выводим минус и берём abs
    test ax, ax
    jns print_dec
    push ax
    mov ah, OUTPUT_STRING
    mov dx, offset msg_minus
    int 21h
    pop ax
    neg ax

print_dec:
    ; выводим десятичное число из AX
    ; делим на 10 и складываем цифры в стек
    mov cx, 0
    mov bx, 10
div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz div_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, OUTPUT_CHAR
    int 21h
    loop print_loop

    mov ah, OUTPUT_STRING
    mov dx, offset msg_nl
    int 21h

    retf
output_short endp

CodeSeg ENDS
END



