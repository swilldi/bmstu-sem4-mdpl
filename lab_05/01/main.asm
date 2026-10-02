.386
include const.inc

EXTERN input_num:far
EXTERN output_binary_num:far
EXTERN output_short:far
EXTERN output_pow2:far

Stk SEGMENT USE16 STACK 'Stk'
    db 100h DUP(?)
Stk ENDS

DataSeg SEGMENT USE16 PUBLIC 'Data'
PUBLIC buf_max, buf_cur, buf_str
    buf_max db BUF_SIZE
    buf_cur db 0
    buf_str db BUF_SIZE DUP(0)

    menu_table dd input_num
               dd output_binary_num
               dd output_short
               dd output_pow2

    msg_menu    db "=== MENU ===", NEW_LINE_CODE, START_LINE_CODE
                db "1. Vvod chisla (hex, 16-bit)", NEW_LINE_CODE, START_LINE_CODE
                db "2. Vyvod bezznakovogo v dvoichnoj", NEW_LINE_CODE, START_LINE_CODE
                db "3. Vyvod usechennogo do 8 bit (znakovoe, dec)", NEW_LINE_CODE, START_LINE_CODE
                db "4. Min stepen dvojki > chislo", NEW_LINE_CODE, START_LINE_CODE
                db "0. Vyhod", NEW_LINE_CODE, START_LINE_CODE
                db "Vash vybor: $"
    msg_newline db NEW_LINE_CODE, START_LINE_CODE, '$'
    msg_bad     db "Nevernyi vybor!", NEW_LINE_CODE, START_LINE_CODE, '$'
DataSeg ENDS

NumbersSeg SEGMENT USE16 COMMON 'Numbers'
    num dw 0
NumbersSeg ENDS

CodeSeg SEGMENT USE16 PUBLIC 'Code'
ASSUME CS:CodeSeg, DS:DataSeg

main:
    mov ax, DataSeg
    mov ds, ax

menu_loop:
    ; вывод меню
    mov ah, OUTPUT_STRING
    mov dx, offset msg_menu
    int 21h

    ; читаем выбор
    mov ah, INPUT_CHAR
    int 21h
    ; новая строка
    push ax
    mov ah, OUTPUT_STRING
    mov dx, offset msg_newline
    int 21h
    pop ax

    cmp al, '0'
    je  exit_prog
    cmp al, '1'
    jb  bad_choice
    cmp al, '4'
    ja  bad_choice

    ; вычисляем индекс в таблице
    sub al, '1'          ; '1'->0, '2'->1, '3'->2, '4'->3
    xor ah, ah
    mov bx, ax
    shl bx, 2            ; * 4 (размер far pointer)

    call dword ptr [menu_table + bx]
    jmp menu_loop

bad_choice:
    mov ah, OUTPUT_STRING
    mov dx, offset msg_bad
    int 21h
    jmp menu_loop

exit_prog:
    mov ah, 4Ch
    xor al, al
    int 21h

CodeSeg ENDS
END main
