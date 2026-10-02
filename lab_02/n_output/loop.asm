StkSeg SEGMENT PARA STACK 'STACK'
    DB 200h DUP (?)
StkSeg ENDS

DataS SEGMENT WORD 'DATA'
        MSG DB 13
            DB 10
            DB "Hello, World!"
            DB "$"
DataS ENDS

Code SEGMENT WORD 'Code'
        ASSUME CS:Code, DS:DataS
PrintMsg:
        mov AX, DataS
        mov DS, AX
        mov DX, OFFSET MSG
        mov AH, 9

        mov CX, 9
        loop1:
                int 21h
                loop loop1
        
        mov AH, 4Ch
        int 21h
Code ENDS
        END PrintMsg


     