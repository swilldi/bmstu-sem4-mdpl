EXTERN output_upper: far
EXTERN chr: byte
EXTERN chr2: byte
PUBLIC main

STK SEGMENT PARA STACK 'STACK'
    db 100h DUP(0)
STK ENDS

CSEG SEGMENT PARA 'CODE'
    assume CS:CSEG
main:
    mov ax, SEG chr2
    mov ds, ax
    
    mov ah, 01  ; чтение числа
    int 21h

    mov chr, al

    jmp output_upper
CSEG ENDS
END main
