StkSeg SEGMENT PARA STACK 'STACK'
    DB 200h DUP (?)
StkSeg ENDS

DataS SEGMENT WORD 'DATA'
        MSG DB 13, 10, "Hello, World!", "$"
DataS ENDS

Code SEGMENT WORD 'CODE'
        ASSUME CS:Code, DS:DataS
PrintMsg:
        mov AX, DataS
        mov DS, AX
        mov DX, OFFSET MSG
        mov AH, 9

        int 21h  ; 1
        int 21h  ; 2
        int 21h  ; 3
        int 21h  ; 4
        int 21h  ; 5
        int 21h  ; 6
        int 21h  ; 7
        int 21h  ; 8
        int 21h  ; 9
        
        mov AH, 4Ch
        int 21h
Code ENDS
        END PrintMsg
