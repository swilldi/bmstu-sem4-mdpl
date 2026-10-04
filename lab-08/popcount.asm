section .text
global _count_bits

_count_bits:
    ; rdi = число
    ; rax = результат
    xor  eax, eax
.loop:
    test rdi, rdi
    jz   .done
    mov  rsi, rdi
    sub  rsi, 1
    and  rdi, rsi       ; n & (n-1) — убирает младшую единицу
    inc  eax
    jmp  .loop
.done:
    ret