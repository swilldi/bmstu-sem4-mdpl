; 32-bit, cdecl
; void my_strcpy(char *dst, const char *src, size_t len);
; Аргументы в стеке справа налево:
;   [esp+4]  = dst
;   [esp+8]  = src
;   [esp+12] = len
; Сохраняем EDI и ESI (callee-saved в cdecl).

bits 32

global my_strcpy

section .text

my_strcpy:
        push    edi
        push    esi
        ; после двух push: смещения +8
        mov     edi, [esp + 12]         ; dst
        mov     esi, [esp + 16]         ; src
        mov     ecx, [esp + 20]         ; len

        test    ecx, ecx
        jz      .done                   ; нечего копировать
        cmp     edi, esi
        je      .done                   ; dst == src
        jb      .forward                ; dst < src  -> копируем вперёд

        ; dst > src: возможно перекрытие, копируем с конца назад
        lea     esi, [esi + ecx - 1]
        lea     edi, [edi + ecx - 1]
        std
        rep     movsb
        cld                             ; восстановить DF (требование ABI)
        jmp     .done

.forward:
        cld
        rep     movsb

.done:
        pop     esi
        pop     edi
        ret
