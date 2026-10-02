
DS2 SEGMENT AT 0b800h
	CA LABEL byte
	ORG 80 * 2 * 2 + 2 * 2  ; 2-я строка 2-й символ 
	SYMB LABEL word
DS2 ENDS

CSEG SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG, ES:DS2
output_X
	mov ax, DS2
	mov es, ax
	mov ah, 10000011b
	mov al, 'n'
	mov symb, ax
CSEG ENDS
END output_X