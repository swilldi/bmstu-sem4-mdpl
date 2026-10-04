.386
include const.inc

PUBLIC output_pow2

NumbersSeg SEGMENT USE16 COMMON 'Numbers'
    num dw ?
NumbersSeg ENDS

DataSeg SEGMENT USE16 PUBLIC 'Data'
    msg_pow  db "Min stepen dvojki > chislo: 2^$"
    msg_nl   db 0Dh, 0Ah, '$'
    msg_zero db "Min stepen dvojki > 0: 2^0 (=1)", 0Dh, 0Ah, '$'
DataSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME CS:CodeSeg, DS:DataSeg

output_pow2 proc far
    mov ax, DataSeg
    mov ds, ax

    ; загружаем num (беззнаковая интерпретация)
    mov ax, NumbersSeg
    mov es, ax
    mov bx, es:[0]

    ; если число == 0: 2^0 = 1 > 0, ответ = 0
    test bx, bx
    jz  zero_case

    ; BSR: найти позицию старшего установленного бита
    ; BSR cx, bx → cx = позиция (0..15)
    ; минимальная степень, которая ПРЕВЫШАЕТ bx = (позиция + 1)
    bsr cx, bx
    inc cx               ; cx = ответ (1..16)

    mov ah, OUTPUT_STRING
    mov dx, offset msg_pow
    int 21h

    ; выводим cx в десятичном виде
    mov ax, cx
    xor ah, ah
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

zero_case:
    mov ah, OUTPUT_STRING
    mov dx, offset msg_zero
    int 21h
    retf

output_pow2 endp

CodeSeg ENDS
END
