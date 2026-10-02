; 64-bit, System V AMD64 ABI (Linux)
; void my_strcpy(char *dst, const char *src, size_t len);
;   rdi = dst
;   rsi = src
;   rdx = len
; RDI и RSI — caller-saved в System V, можно затирать.
; DF на входе/выходе функции должен быть 0.

bits 64

global my_strcpy

section .text

my_strcpy:
        mov     rcx, rdx
        test    rcx, rcx
        jz      .done
        cmp     rdi, rsi
        je      .done
        jb      .forward                ; dst < src -> вперёд

        ; dst > src: копируем с конца назад
        lea     rsi, [rsi + rcx - 1]
        lea     rdi, [rdi + rcx - 1]
        std
        rep     movsb
        cld
        ret

.forward:
        cld
        rep     movsb

.done:
        ret
