data segment
    buffer db 7, 8 dup(0)
;.................
    temp DW 2 dup(0)      ;переменная для сохранения частного от деления на 10
data ends
;.................
code segment
    assume cs:code,ds:data
begin:
    mov ax,data
    mov ds,ax
    call vvodCD
    call calculate
    ; вывод результата
    mov ah,09h          ; сообщение
    lea dx,otvet
    int 21h
    mov ax, word ptr [dorez]
    mov dx, word ptr [dorez+2]
    call ShowUInt32
    mov ah,1            ; ожидание нажатия
    int 21h
 
    mov ax, 4c00h
    int 21h
;.....................
;Вывод на экран целого 32 разрядного беззнакового числа
;на входе:
;  dx:ax - целое 32 разрядное беззнаковое число
ShowUInt32:
 
        ;сохранить значение числа во временной переменной
        mov     word ptr temp[0],       ax
        mov     word ptr temp[2],       dx
;....................
@@ShowDigit:
        pop     dx              ;извлечение цифры из стека
        int     21h             ;вывод символа на экран
        loop    @@ShowDigit
 
        ret
 
code ends
END begin