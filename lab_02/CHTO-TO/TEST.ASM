StkSeg SEGMENT STACK 'STACK'
        DB 200h DUP(?)
StkSeg ENDS

DataS SEGMENT WORD 'DATA'
MSG     DB 10h         ; Максимальная длина
        DB 00h         ; Введенная длина
        DB 10h DUP (?)  ; место под 16 символов
        DB '$'
DataS ENDS

Code SEGMENT WORD 'CODE'
        ASSUME CS:Code, DS:DataS
Prog:
        ; подготовка DS
        mov AX, DataS           
        mov DS, AX

        ; Смещение на строку
        mov DX, OFFSET MSG

        ; Ввод строки
        mov AH, 0Ah
        int 21h

        mov AH, [DX + 1]
        mov [DX + 1 + AH], '$'

        mov AH, 4Ch
        int 21h
Code ENDS
        END Prog