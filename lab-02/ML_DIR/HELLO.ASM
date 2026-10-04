; Сегмент с именем StkSeg, выравниванием PARA (то есть параграф -> адреса кратные 16), тип STACK, класса 'STACK'
StkSeg SEGMENT PARA STACK 'STACK'
    DB 200h DUP (?)
StkSeg ENDS

DataS SEGMENT WORD 'DATA'
HelloMsg  DB 13 ;курсор на начало строки
          DB 10 ;курсор на новую строку
          DB 'Hello, World!' ; текст сообщения
          DB '$' ; признак окончания строки для DOS
DataS ENDS

Code SEGMENT WORD 'CODE'
    ASSUME CS:Code, DS:DataS
DispMsg:
    mov AX, DataS
    mov DS, AX
    mov DX, OFFSET HelloMsg
    mov AH, 9
    int 21h
    mov AH, 7
    int 21h
    mov AH, 4Ch
    int 21h
Code ENDS
    END DispMsg
