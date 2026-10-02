PUBLIC output_upper
PUBLIC chr
PUBLIC chr2

upper_shift EQU ('a' - 'A')
new_line_code EQU 10
start_line_code EQU 13

DataS SEGMENT PARA PUBLIC 'DATA'
    chr db 0
    chr2 db 0
DataS ENDS

OUT_CSEG SEGMENT PARA 'CODE'
    assume CS:OUT_CSEG, DS:DataS
output_upper:
    mov ax, DataS
    mov ds, ax

    sub chr, upper_shift  ; букву в верхний регистр
    
    ; call new_line
    call add_space
    mov ah, 02h
    mov dl, chr      ; вывод символа
    int 21h
    
    mov ah, 4Ch
    int 21h

new_line proc near
    mov ah, 02h
    
    mov dl, new_line_code   ; переход на следующую строку
    int 21h

    mov dl, start_line_code ; переход к началу строки
    int 21h

    ret
new_line endp

add_space proc near
    mov ah, 02h
    mov dl, ' '
    int 21h
    ret
add_space endp

OUT_CSEG ENDS
END
