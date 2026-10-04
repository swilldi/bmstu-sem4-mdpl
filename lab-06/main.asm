.386

OK EQU 0

TICKS_IN_SECOND EQU 18
MAX_SPEED EQU 0
MIN_SPEED EQU 11111b

StkSeg SEGMENT USE16 STACK 'STACK'
    db 100h DUP(?)
StkSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME cs:CodeSeg, ds:CodeSeg, es:CodeSeg, ss:StkSeg

tick_counter db 18
speed db MIN_SPEED
old_int8_handler dd ?

my_int_8h:
    push ax
    push bx
    push ds
    push es

    mov ax, CodeSeg
    mov ds, ax

    inc tick_counter
    cmp tick_counter, TICKS_IN_SECOND
    jb my_int_8h_done

    mov ah, 03h
    mov al, 05h
    mov bh, 0
    mov bl, speed
    int 16h

    ; Обновление скорости
    mov tick_counter, 0

    cmp speed, MAX_SPEED
    je reset_speed

    dec speed
    jmp my_int_8h_done

reset_speed:
    mov speed, MIN_SPEED
    
my_int_8h_done:
    ; отображение текущей скорости
    mov dl, 10
    xor ah, ah
    mov al, speed
    div dl
    add al, '0'
    add ah, '0'

    mov bx, 0B800h
    mov es, bx
    mov bx, 78 * 2

    mov byte ptr es:[bx], al
    mov byte ptr es:[bx+1], 00100000b
    mov byte ptr es:[bx+2], ah
    mov byte ptr es:[bx+3], 00100000b

    pop  es
    pop  ds
    pop  bx
    pop  ax
    jmp dword ptr cs:[old_int8_handler]
my_int_8h_end:

main:
    psp_seg dw 0

    mov ax, CodeSeg
    mov ds, ax

    mov ax, es
    mov psp_seg, ax  ; сохраняем сегмент PSP

    ; -- подмена прерывания таймера --
    ; получени старого адреса прерывания в ES:BX
    mov ah, 35h
    mov al, 08h
    int 21h 
    mov word ptr old_int8_handler, bx
    mov word ptr old_int8_handler+2, es

    ; подмена прерывания int 8h
    mov dx, offset my_int_8h
    mov ah, 25h
    mov al, 08h 
    int 21h
    
    ; -- Вывод для проверки, что ничего не зависло -- 
    mov ah, 02h
    mov dl, 'O'
    int 21h
    


    ; -- Удаляем PSP --
    ; Создаем MCB в конце PSP
    mov ax, psp_seg
    mov es, ax

    mov bx, 0F0h

    mov byte ptr es:[bx], 'M'
    mov word ptr es:[bx + 1], ax
    mov word ptr es:[bx + 3], 10h

    ; Уменьшаем размер MCB для PSP
    mov bx, psp_seg
    dec bx
    mov es, bx

    mov ax, es:[3]
    sub ax, 1h
    mov es:[3], ax

    ; Освобождаем PSP
    mov ax, psp_seg
    mov es, ax
    mov ah, 49h
    int 21h


    ; Вычисление количества параграфов
    mov dx, offset my_int_8h_end
    add dx, 15
    shr dx, 4

    ; Заверщение резидентно
    mov ah, 31h
    mov al, OK
    int 21h

CodeSeg ENDS
END main


