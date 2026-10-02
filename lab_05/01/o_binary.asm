.386
include const.inc

PUBLIC output_binary_num

NumbersSeg SEGMENT USE16 COMMON 'Numbers'
    num dw ?
NumbersSeg ENDS

DataSeg SEGMENT USE16 PUBLIC 'Data'
    msg_bin db "Bezznakovoe v dvoichnoj: $"
    msg_nl  db 0Dh, 0Ah, '$'
DataSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME CS:CodeSeg, DS:DataSeg

output_binary_num proc far
    mov ax, DataSeg
    mov ds, ax

    mov ah, OUTPUT_STRING
    mov dx, offset msg_bin
    int 21h

    mov ax, NumbersSeg
    mov es, ax
    mov bx, es:[0]       ; num (беззнаковая интерпретация)

    mov cx, 16
binary_loop:
    shl bx, 1
    mov dl, '0'
    adc dl, 0
    mov ah, OUTPUT_CHAR
    int 21h
    loop binary_loop

    mov ah, OUTPUT_STRING
    mov dx, offset msg_nl
    int 21h

    retf
output_binary_num endp

CodeSeg ENDS
END
