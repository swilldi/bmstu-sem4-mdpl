; nasm -f macho64 main.asm
; GTK4 + NASM x86_64 popcount
default rel

extern _gtk_init
extern _gtk_application_new
extern _gtk_application_window_new
extern _gtk_window_set_title
extern _gtk_window_set_default_size
extern _gtk_box_new
extern _gtk_widget_set_margin_start
extern _gtk_widget_set_margin_end
extern _gtk_widget_set_margin_top
extern _gtk_widget_set_margin_bottom
extern _gtk_box_set_spacing
extern _gtk_entry_new
extern _gtk_entry_buffer_get_text
extern _gtk_entry_get_buffer
extern _gtk_label_new
extern _gtk_button_new_with_label
extern _gtk_box_append
extern _gtk_window_set_child
extern _gtk_widget_show
extern _g_signal_connect_data
extern _g_application_run
extern _g_object_unref
extern _atoll
extern _snprintf
extern _gtk_label_set_text
extern _count_bits

section .data
    app_id      db "org.asm.popcount", 0
    win_title   db "Popcount — GTK4 + ASM", 0
    btn_label   db "Посчитать биты", 0
    lbl_init    db "Результат появится здесь", 0
    entry_hint  db "Введите целое число...", 0
    fmt_result  db "Единиц в двоичной записи: %llu", 0
    sig_activate db "activate", 0
    sig_clicked  db "clicked", 0

    ; GTK orientation: GTK_ORIENTATION_VERTICAL = 1
    GTK_ORIENTATION_VERTICAL  equ 1
    GTK_ORIENTATION_HORIZONTAL equ 0

section .bss
    app_ptr     resq 1      ; GtkApplication*
    entry_ptr   resq 1      ; GtkEntry*
    label_ptr   resq 1      ; GtkLabel* для результата
    result_buf  resb 128    ; буфер для строки результата

section .text
global _main

; ─────────────────────────────────────────
; on_activate(app, user_data)
; строит всё окно
; ─────────────────────────────────────────
on_activate:
    push rbp
    mov  rbp, rsp
    sub  rsp, 48

    ; window = gtk_application_window_new(app)
    mov  rdi, [app_ptr]
    call _gtk_application_window_new
    mov  [rbp-8], rax           ; сохранить window

    ; gtk_window_set_title(window, title)
    mov  rdi, rax
    lea  rsi, [rel win_title]
    call _gtk_window_set_title

    ; gtk_window_set_default_size(window, 360, 200)
    mov  rdi, [rbp-8]
    mov  rsi, 360
    mov  rdx, 200
    call _gtk_window_set_default_size

    ; box = gtk_box_new(VERTICAL, 0)
    mov  rdi, GTK_ORIENTATION_VERTICAL
    mov  rsi, 0
    call _gtk_box_new
    mov  [rbp-16], rax          ; сохранить box

    ; отступы у box
    mov  rdi, rax
    mov  rsi, 20
    call _gtk_widget_set_margin_start
    mov  rdi, [rbp-16]
    mov  rsi, 20
    call _gtk_widget_set_margin_end
    mov  rdi, [rbp-16]
    mov  rsi, 20
    call _gtk_widget_set_margin_top
    mov  rdi, [rbp-16]
    mov  rsi, 20
    call _gtk_widget_set_margin_bottom
    mov  rdi, [rbp-16]
    mov  rsi, 12
    call _gtk_box_set_spacing

    ; entry = gtk_entry_new()
    call _gtk_entry_new
    mov  [entry_ptr], rax
    ; добавить entry в box
    mov  rdi, [rbp-16]
    mov  rsi, rax
    call _gtk_box_append

    ; button = gtk_button_new_with_label("Посчитать биты")
    lea  rdi, [rel btn_label]
    call _gtk_button_new_with_label
    mov  [rbp-24], rax          ; сохранить button
    ; добавить в box
    mov  rdi, [rbp-16]
    mov  rsi, rax
    call _gtk_box_append

    ; label = gtk_label_new("Результат...")
    lea  rdi, [rel lbl_init]
    call _gtk_label_new
    mov  [label_ptr], rax
    ; добавить в box
    mov  rdi, [rbp-16]
    mov  rsi, rax
    call _gtk_box_append

    ; gtk_window_set_child(window, box)
    mov  rdi, [rbp-8]
    mov  rsi, [rbp-16]
    call _gtk_window_set_child

    ; g_signal_connect(button, "clicked", on_button_click, 0)
    mov  rdi, [rbp-24]
    lea  rsi, [rel sig_clicked]
    lea  rdx, [rel on_button_click]
    xor  ecx, ecx
    xor  r8d, r8d
    xor  r9d, r9d
    call _g_signal_connect_data

    ; gtk_widget_show(window)
    mov  rdi, [rbp-8]
    call _gtk_widget_show

    leave
    ret

; ─────────────────────────────────────────
; on_button_click(button, user_data)
; читает entry, считает биты, обновляет label
; ─────────────────────────────────────────
on_button_click:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32

    ; buffer = gtk_entry_get_buffer(entry)
    mov  rdi, [entry_ptr]
    call _gtk_entry_get_buffer

    ; text = gtk_entry_buffer_get_text(buffer)
    mov  rdi, rax
    call _gtk_entry_buffer_get_text   ; rax = const char*

    ; n = atoll(text)
    mov  rdi, rax
    call _atoll
    mov  [rbp-8], rax

    ; result = count_bits(n)
    mov  rdi, rax
    call _count_bits
    mov  [rbp-16], rax

    ; snprintf(result_buf, 128, fmt, result)
    lea  rdi, [result_buf]
    mov  rsi, 128
    lea  rdx, [fmt_result]
    mov  rcx, [rbp-16]
    xor  eax, eax
    call _snprintf

    ; gtk_label_set_text(label, result_buf)
    mov  rdi, [label_ptr]
    lea  rsi, [result_buf]
    call _gtk_label_set_text

    leave
    ret

; ─────────────────────────────────────────
; main
; ─────────────────────────────────────────
_main:
    push rbp
    mov  rbp, rsp

    ; app = gtk_application_new(id, 0)
    lea  rdi, [rel app_id]
    xor  esi, esi
    call _gtk_application_new
    mov  [app_ptr], rax

    ; g_signal_connect(app, "activate", on_activate, 0)
    mov  rdi, rax
    lea  rsi, [rel sig_activate]
    lea  rdx, [rel on_activate]
    xor  ecx, ecx
    xor  r8d, r8d
    xor  r9d, r9d
    call _g_signal_connect_data

    ; g_application_run(app, 0, 0)
    mov  rdi, [app_ptr]
    xor  esi, esi
    xor  edx, edx
    call _g_application_run

    ; g_object_unref(app)
    mov  rdi, [app_ptr]
    call _g_object_unref

    xor  eax, eax
    leave
    ret