section .data
    input_a_msg db "Input a: ", 0
    input_b_msg db "Input b: ", 0
    input_N_msg db "Input N: ", 0

    input_error_msg db "Invalid input", 10, 0
    max_iter_error_msg db "Max iter", 10, 0
    result_fmt db "x = %f", 10, 0
    debug_fmt db "x=%.10f f_x=%.10f", 10, 0

    input_double_fmt db "%lf", 0
    input_int_fmt db "%d", 0

    max_iter_flag db 0

    two dq 2.0
    five dq 5.0

    a dq 0.0
    b dq 0.0
    N dd 0
    x dq 0.0

    f_a dq 0.0
    f_b dq 0.0
    f_x dq 0.0

    eps dq 1e-5


section .text
    global main
    extern printf
    extern scanf

read_double:
    push ebp
    mov ebp, esp

    push dword [ebp + 8]
    push input_double_fmt
    call scanf
    add esp, 8

    pop ebp
    ret

read_int:
    push ebp
    mov ebp, esp

    push dword [ebp + 8]
    push input_int_fmt
    call scanf
    add esp, 8

    pop ebp
    ret

input_error_msg_print:
    push input_error_msg
    call printf
    add esp, 4
    jmp prog_end

max_iter_msg_print:
    push max_iter_error_msg
    call printf
    add esp, 4
    jmp prog_end

func:
    push ebp
    mov ebp, esp
    push ecx

    fld qword [ebp + 8]
    fld qword [ebp + 8]
    fmulp
    fld qword [five]
    fsubp
    
    fsin
    
    fld qword [two]
    fmulp
    
    pop ecx
    pop ebp
    ret

find_x:
    push ebp
    mov ebp, esp

    push dword [a + 4]
    push dword [a]
    call func
    add esp, 8
    fstp qword [f_a]

    push dword [b + 4]
    push dword [b]
    call func
    add esp, 8
    fstp qword [f_b]

    mov ecx, [N]

.loop:
    dec ecx
    jnz .continue

    mov byte [max_iter_flag], 1 
    jmp .done
    
.continue:
    push ecx
    push dword [f_x + 4]
    push dword [f_x]
    push dword [x + 4]
    push dword [x]
    push debug_fmt
    call printf
    add esp, 20
    pop ecx

    ; x = a - f(a) * (b - a) / (f(b) - f(a))
    fld qword [a]
    fld qword [f_a]
    fld qword [b]
    fld qword [a]
    fsubp           ; b - a
    fmulp           ; f(a) * (b - a)

    fld qword [f_b]       
    fld qword [f_a]
    fsubp           ; f(b) - f(a)
    fdivp           ; f(a) * (b - a) / f(b) - f(a)
    fsubp           ; a - ^
    
    ; f(x)
    fstp qword [x]
    push dword [x + 4]
    push dword [x]
    call func
    add esp, 8
    fstp qword [f_x]

    ; |f(x)| < eps
    fld qword [eps]
    fld qword [f_x]
    fabs
    fcomip st0, st1
    fstp st0
    jb .done

    ; f_a * f_x < 0
    fldz
    fld qword [f_a]
    fld qword [f_x]
    fmulp 
    fcomip st0, st1 ; st(0) = 0, st(1) = f_a * f_b
    fstp st0
    jb .update_b

    ; f(x) * f(a) >= 0 -> a = x
    fld qword [x]
    fstp qword [a]
    fld qword [f_x]
    fstp qword [f_a]
    jmp .loop

    ; f(x) * f(a) < 0 -> b = x
.update_b:
    fld qword [x]
    fstp qword [b]
    fld qword [f_x]
    fstp qword [f_b]
    jmp .loop

.done:
    pop ebp
    ret

main:
    push ebp
    mov ebp, esp

    push input_a_msg
    call printf
    add esp, 4

    push a
    call read_double
    add esp, 4
    cmp eax, 1
    jne input_error_msg_print

    push input_b_msg
    call printf
    add esp, 4

    push b
    call read_double
    add esp, 4
    cmp eax, 1
    jne input_error_msg_print

    ; проверка на a < b
    fld qword [b]
    fld qword [a]
    fcomip st0, st1
    fstp st0
    jae input_error_msg_print

    push input_N_msg
    call printf
    add esp, 4

    push N
    call read_int
    add esp, 4
    cmp eax, 1
    jne input_error_msg_print

    ; проверка N > 0
    cmp dword [N], 0
    jle input_error_msg_print


    call find_x

    cmp byte [max_iter_flag], 1
    je max_iter_msg_print

    ; вывод результата
    push dword [x + 4]
    push dword [x]
    push result_fmt
    call printf
    add esp, 12

    jmp prog_end
    

prog_end:
    xor eax, eax
    pop ebp
    ret
