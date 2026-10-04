#include <stdio.h>

#define array_data_t float
#define array_t array_data_t*

float scalarMult(array_t arr1, array_t arr2, size_t len) {

    asm volatile("movi v2.4s, #0\n\t" ::: "v2");

    size_t i = 0;
    for (; i + 4 <= len; i += 4) {
        asm volatile(
            "ld1    {v0.4s}, [%[arr1]]\n\t"
            "ld1    {v1.4s}, [%[arr2]]\n\t"
            "fmla   v2.4s, v0.4s, v1.4s\n\t"   // f — float multiply-accumulate
            :
            : [arr1] "r"(arr1 + i), [arr2] "r"(arr2 + i)
            : "memory", "v0", "v1", "v2"
        );
    }

    float result = 0;
    asm volatile(
        "faddp  v2.4s, v2.4s, v2.4s\n\t"   // свёртка float: попарно
        "faddp  v2.4s, v2.4s, v2.4s\n\t"   // ещё раз — сумма всех 4 в полосе 0
        "fmov   %s0, s2\n\t"               // s2 -> результат (оба float-банк)
        : "=w"(result)                      // =w : операнд в векторном/FP регистре!
        :
        : "v2"
    );

    for (; i < len; ++i) {
        asm volatile(
            "ldr    s0, [%1]\n\t"           // грузим float в s-регистр
            "ldr    s1, [%2]\n\t"
            "fmadd  %s0, s0, s1, %s0\n\t"   // float multiply-add
            : "+w"(result)                  // +w : тоже FP-регистр
            : "r"(arr1 + i), "r"(arr2 + i)
            : "memory", "v0", "v1"
        );
    }

    return result;
}

int main(void) {
    array_data_t arr1[] = { 1, 2, 3, 4 };
    array_data_t arr2[] = { 2, 2, 1, 2 };
    printf("%f\n", scalarMult(arr1, arr2, 4));      // 17.0

    array_data_t arr3[] = { 1, 2, 3, 4, 1 };
    array_data_t arr4[] = { 2, 2, 1, 2, 10 };
    printf("%f\n", scalarMult(arr3, arr4, 5));      // 27.0
}