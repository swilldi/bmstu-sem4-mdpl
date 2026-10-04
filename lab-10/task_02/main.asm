section .data
    fmt_res db "=== VALUE ===", 10
            db "=== short ===", 10
            db "sin(pi)   = %f", 10
            db "sin(pi/2) = %f", 10
            db "=== ===== ===", 10, 10
            db "=== long  ===", 10
            db "sin(pi)   = %f", 10
            db "sin(pi/2) = %f", 10,
            db "=== ===== ===", 10, 10
            db "=== system ===", 10
            db "sin(pi)   = %f", 10
            db "sin(pi/2) = %f", 10
            db "=== ===== ===", 10, 0

    fmt_abs db 10, 10, "=== ABS  ===", 10
            db "=== short ===", 10
            db "sin(pi)   = %f", 10
            db "sin(pi/2) = %f", 10
            db "=== ===== ===", 10, 10
            db "=== long ===", 10
            db "sin(pi)   = %f", 10
            db "sin(pi/2) = %f", 10,
            db "=== ===== ===", 10, 0

    fmt_rel db 10, 10, "=== REL  ===", 10
            db "=== short ===", 10
            db "sin(pi)   = %e", 10
            db "sin(pi/2) = %e", 10
            db "=== ===== ===", 10, 10
            db "=== long ===", 10
            db "sin(pi)   = %e", 10
            db "sin(pi/2) = %e", 10,
            db "=== ===== ===", 10, 0

    short_pi dq 3.14
    long_pi dq 3.141596
    two dq 2.0
    hundred dq 100.0

    res_short_sin_pi dq 0
    res_short_sin_hpi dq 0

    res_long_sin_pi dq 0
    res_long_sin_hpi dq 0

    res_system_sin_pi dq 0
    res_system_sin_hpi dq 0

    
    short_abs_error_pi dq 0
    short_abs_error_hpi dq 0
    short_rel_error_pi dq 0
    short_rel_error_hpi dq 0

    long_abs_error_pi dq 0
    long_abs_error_hpi dq 0
    long_rel_error_pi dq 0
    long_rel_error_hpi dq 0
    


section .text
    extern printf
    global main

solve_short_sin:
    push ebp
    mov ebp, esp

    fld qword [short_pi]
    fsin
    fstp qword [res_short_sin_pi]

    pop ebp
    ret

solve_short_sin_half:
    push ebp
    mov ebp, esp

    fld qword [short_pi]
    fld qword [two]
    fdivp ; 3.14 / 2

    fsin

    fstp qword [res_short_sin_hpi]

    pop ebp
    ret


solve_long_sin:
    push ebp
    mov ebp, esp

    fld qword [long_pi]
    fsin
    fstp qword [res_long_sin_pi]

    pop ebp
    ret

solve_long_sin_half:
    push ebp
    mov ebp, esp

    fld qword[long_pi]
    fld qword[two]
    fdivp

    fsin
    fstp qword [res_long_sin_hpi]

    pop ebp
    ret


solve_system_sin:
    push ebp
    mov ebp, esp

    fldpi

    fsin

    fstp qword [res_system_sin_pi]

    pop ebp
    ret 

solve_system_sin_half:
    push ebp
    mov ebp, esp

    fldpi
    fld qword [two]
    fdivp

    fsin

    fstp qword [res_system_sin_hpi]
    pop ebp
    ret

print_res:
    push ebp
    mov ebp, esp

    ; system pi
    push dword [res_system_sin_hpi + 4]
    push dword [res_system_sin_hpi]
    push dword [res_system_sin_pi + 4]
    push dword [res_system_sin_pi]

    ; long pi
    push dword [res_long_sin_hpi + 4]
    push dword [res_long_sin_hpi]
    push dword [res_long_sin_pi + 4]
    push dword [res_long_sin_pi]

    ; short pi
    push dword [res_short_sin_hpi + 4]
    push dword [res_short_sin_hpi]
    push dword [res_short_sin_pi + 4]
    push dword [res_short_sin_pi]

    push fmt_res
    call printf
    add esp, 52

    pop ebp
    ret


solve_abs_errors:
    push ebp
    mov ebp, esp

    ; short_abs_error_pi
    fld qword [res_system_sin_pi]
    fld qword [res_short_sin_pi]
    fsubp
    fabs
    fstp qword [short_abs_error_pi]

    ; short_abs_error_hpi
    fld qword [res_system_sin_hpi]
    fld qword [res_short_sin_hpi]
    fsubp
    fabs
    fstp qword [short_abs_error_hpi]

    ; long_abs_error_pi
    fld qword [res_system_sin_pi]
    fld qword [res_long_sin_pi]
    fsubp
    fabs
    fstp qword [long_abs_error_pi]

    ; long_abs_error_hpi
    fld qword [res_system_sin_hpi]
    fld qword [res_long_sin_hpi]
    fsubp
    fabs
    fstp qword [long_abs_error_hpi]

    pop ebp
    ret

solve_rel_errors:
    push ebp
    mov ebp, esp

    ; short_rel_error_pi

    fld qword [hundred]             ; st(2)
    fld qword [short_abs_error_pi]  ; st(1)
    fld qword [res_system_sin_pi]   ; st(0)
    fdivp                           ; st(0) = st(1) / st(0), st(1) = st(2)
    fmulp                           ; st(0) = st(0) * st(1)

    fstp qword [short_rel_error_pi]

    ; short_rel_error_hpi
    fld qword [hundred]
    fld qword [short_abs_error_hpi]
    fld qword [res_system_sin_hpi]
    fdivp 
    fmulp

    fstp qword [short_rel_error_hpi]

    ; long_rel_error_pi
    fld qword [hundred]
    fld qword [long_abs_error_pi]
    fld qword [res_system_sin_pi]
    fdivp 
    fmulp

    fstp qword [long_rel_error_pi]

    ; long_rel_error_hpi
    fld qword [hundred]
    fld qword [long_abs_error_hpi]
    fld qword [res_system_sin_hpi] 
    fdivp 
    fmulp

    fstp qword [long_rel_error_hpi]
    
    pop ebp
    ret

print_abs_error:
    push ebp
    mov ebp, esp

    push dword [long_abs_error_hpi + 4]
    push dword [long_abs_error_hpi]
    push dword [long_abs_error_pi + 4]
    push dword [long_abs_error_pi]
    
    push dword [short_abs_error_hpi + 4]
    push dword [short_abs_error_hpi]
    push dword [short_abs_error_pi + 4]
    push dword [short_abs_error_pi]
    

    push fmt_abs

    call printf

    add esp, 36 

    pop ebp
    ret

print_rel_error:
    push ebp
    mov ebp, esp

    
    push dword [long_rel_error_hpi + 4]
    push dword [long_rel_error_hpi]
    push dword [long_rel_error_pi + 4]
    push dword [long_rel_error_pi]

    push dword [short_rel_error_hpi + 4]
    push dword [short_rel_error_hpi]
    push dword [short_rel_error_pi + 4]
    push dword [short_rel_error_pi]

    push fmt_rel

    call printf

    add esp, 36 

    pop ebp
    ret 

main:
    push ebp
    mov ebp, esp


    call solve_short_sin
    call solve_short_sin_half
    call solve_long_sin
    call solve_long_sin_half
    call solve_system_sin
    call solve_system_sin_half

    call print_res

    call solve_abs_errors
    call print_abs_error

    call solve_rel_errors
    call print_rel_error

    xor eax, eax
    pop ebp
    ret
