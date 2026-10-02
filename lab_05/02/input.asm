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

StrSeg SEGMENT USE16 PUBLIC 'String'
    ; Вводимая строка
    buf_max_len db BUFER_MAX_LEN
    buf_cur_len db 0
    buf_str db BUFER_MAX_LEN DUP(0)

    ; Приглашение ко вводу
    input_msg db "Vvedite znakovoe chislo v 16 c/c: ", '$'
    ; Ошибка ввода
    error_msg db "Invalid input", NEW_LINE, START_LEN, '$'


StrSeg ENDS

; Общий сегмент с числом
NumSeg SEGMENT USE16 COMMON 'Number'
    number label word
NumSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME DS:StrSeg, ES:NumSeg, CS:CodeSeg


str_to_hex proc far
    push ds
    mov ax, StrSeg
    mov ds, ax

    xor ch, ch
    mov cl, buf_cur_len

    ; проверка что строка не пустая
    test cl, cl
    jz error

    mov si, offset buf_str
    xor ax, ax
    xor dx, dx

    ; установление знака
    cmp byte ptr [si], '-'
    jne check_len
    mov dx, 1
    inc si
    dec cx

    ; после минуса должны быть символы
    test cl, cl
    jz error

    check_len:
        cmp cx, 4
        ja error

    conv_loop:
        xor bx, bx
        mov bl, [si]

        ; проверка допустимых символов
        cmp bl, '0'
        jb error
        cmp bl, '9'
        jbe digit_char
        or bl, 20h
        cmp bl, 'a'
        jb error
        cmp bl, 'f'
        ja error

    digit_char:
        cmp bl, '9'         ; снова проверяем — bl мог измениться от or
        jbe is_digit
        sub bl, 'a'
        add bl, 10
        jmp conv_char_end
    is_digit:
        sub bl, '0'

    conv_char_end:
        shl ax, HEX_SHIFT
        or ax, bx
        inc si
        loop conv_loop

    ; проверка переполнения
    test dx, dx
    jz check_overflow_pos

    ; отрицательное: значение не должно быть > 8000h
    cmp ax, 8000h
    ja error
    neg ax
    jmp save

    check_overflow_pos:
        test ax, 8000h
        jnz error

    save:
        mov es:[number], ax
        jmp exit

    error:
        mov ah, OUTPUT_CHAR_CODE
        mov dl, NEW_LINE
        int 21h
        mov dl, START_LEN
        int 21h

        mov ah, OUTPUT_STR_CODE
        mov dx, offset error_msg
        int 21h

exit:
    pop ds
    ret

str_to_hex endp

;input_number proc
input_sign_hex proc
    pusha
    push ds

    mov ax, StrSeg
    mov ds, ax

    ; приглашение к вводу
    mov ah, OUTPUT_STR_CODE
    mov dx, offset input_msg
    int 21h
    
    ; ввод строки
    mov ah, INPUT_STR_CODE
    mov dx, offset buf_max_len
    int 21h

    ; Добавлнение конца строки
    ; mov bx, offset buf_str
    ; mov al, buf_cur_len
    ; xor ah, ah
    ; mov di, ax
    ; mov byte ptr [bx + di], '$'

    ; вывод строки
    ;mov ah, OUTPUT_STR_CODE
    ;mov dx, offset buf_str
    ;int 21h

    call str_to_hex
    
    pop ds
    popa
    retf
; input_number endp
input_sign_hex endp
CodeSeg ENDS
END
