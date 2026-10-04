.386

EXTERN input_sign_hex: far
EXTERN output_unsign_binary: far
EXTERN output_sign_short: far
EXTERN min_degree: far


BUFER_MAX_LEN EQU 20

INPUT_CHAR_ECHO_CODE EQU 01
OUTPUT_CHAR_CODE EQU 02

INPUT_STR_CODE EQU 0Ah
OUTPUT_STR_CODE EQU 09

NEW_LINE EQU 13
START_LEN EQU 10
END_STRING EQU '$'


StackSeg SEGMENT USE16 Stack "Stk"
    db 100h DUP(0)
StackSeg ENDS

; Общий сегмент с числом
NumSeg SEGMENT USE16 COMMON 'Number'
    number dw 11111111b
NumSeg ENDS

DataSeg SEGMENT USE16 'Data'
    ; Таблица переходов
    menu_table  dd input_sign_hex        ; ввод знаковое 16 с/с
                dd output_unsign_binary  ; вывод беззнаковое 2 с/с
                dd output_sign_short     ; вывод учесенного до 8 разрядов знакового в 10 с/с
                dd min_degree            ; минималное n такое что 2^n > input_num
                ; dd 4 DUP(0)

    ; Сообщения для вывода
    menu_command_msg db "--------------------------------------", NEW_LINE, START_LEN
                     db "1. Vvod chisla", NEW_LINE, START_LEN
                     db "2. Vivod bezznakovogo v 2 c/c", NEW_LINE, START_LEN
                     db "3. Vivod korotkogo znakovogo v 10 c/c", NEW_LINE, START_LEN
                     db "4. Min stepen 2, bolshe chisla", NEW_LINE, START_LEN
                     db "0. Vihod", NEW_LINE, START_LEN
                     db "--------------------------------------", NEW_LINE, START_LEN
                     db END_STRING


    input_command_msg db "Vvedite comandu: ", END_STRING
    invalid_command_msg db "COMANDA INVALIDA", END_STRING, NEW_LINE, START_LEN
DataSeg ENDS


CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME DS:DataSeg, ES:NumSeg, CS:CodeSeg

print_new_line proc
    pusha
    mov ah, OUTPUT_CHAR_CODE
    mov dl, NEW_LINE
    int 21h
    mov dl, START_LEN
    int 21h
    popa
    ret
print_new_line endp


print_error_msg:
    mov ah, OUTPUT_STR_CODE
    mov dx, offset invalid_command_msg
    int 21h
    call print_new_line
    call print_new_line
    jmp command_loop

main:
    ; Настройка сегментов
    mov ax, DataSeg
    mov ds, ax

    mov ax, NumSeg
    mov es, ax

command_loop:
    mov dx, offset menu_command_msg
    mov ah, OUTPUT_STR_CODE
    int 21h

    mov ah, OUTPUT_STR_CODE
    mov dx, offset input_command_msg
    int 21h

    ; ввод команды
    xor ax, ax
    mov ah, INPUT_CHAR_ECHO_CODE
    int 21h

    ; Обработка ввода
    cmp al, '0'
    je end_prog

    call print_new_line

    cmp al, '1'
    jb print_error_msg
    cmp al, '4'
    ja print_error_msg

    xor ah, ah
    mov bx, ax
    sub bx, '1'
    shl bx, 2 

    call dword ptr [menu_table + bx]
    call print_new_line

    jmp command_loop
    

end_prog:
    mov ax, 4C00h
    int 21h

CodeSeg ENDS
END main

