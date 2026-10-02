#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 1000
#define MANTISA_LEN 100000
#define TEST_COUNT 1000


void generate_arr(double *d_arr, float *f_arr) {
    srand(time(NULL));

    for (size_t i = 0; i < N; ++i) {
        d_arr[i] = (double)rand() / 1000;
        f_arr[i] = (float)rand() / 1000;
    }
}

void pre_test_float_asm(float *f_arr_a, float *f_arr_b, size_t test_count) {
    volatile double s;
    for (size_t c = 0; c < test_count; ++c) {        
        // Сложение float
        for (size_t i = 0; i < N; ++i) {
            s = f_arr_a[i] + f_arr_b[i];
        }


        // Умножение float
        for (size_t i = 0; i < N; ++i) {
            s = f_arr_a[i] * f_arr_b[i];
        }
    }
}

void run_test_float_asm(double *res_time_s, double *res_time_m, float *f_arr_a, float *f_arr_b, size_t test_count) {
    double res_mul = 0, res_sum = 0;
    volatile double s;

    struct timespec start, end;
    for (size_t c = 0; c < test_count; ++c) {
        
        
        // Сложение float
        clock_gettime(CLOCK_MONOTONIC, &start);
        for (size_t i = 0; i < N; ++i) {
            s = f_arr_a[i] + f_arr_b[i];
        }
        clock_gettime(CLOCK_MONOTONIC, &end);
        res_sum += (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);


        // Умножение float
        clock_gettime(CLOCK_MONOTONIC, &start);
        for (size_t i = 0; i < N; ++i) {
            s = f_arr_a[i] * f_arr_b[i];
        }
        clock_gettime(CLOCK_MONOTONIC, &end);
        res_mul += (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
    }

    *res_time_s = res_sum / test_count / N;
    *res_time_m = res_mul / test_count / N;
}



void pre_test_double_asm(double *d_arr_a, double *d_arr_b, size_t test_count) {
    double res_mul = 0, res_sum = 0;
    volatile double s;

    struct timespec start, end;
    for (size_t c = 0; c < test_count; ++c) {
        // Сложение double
        for (size_t i = 0; i < N; ++i) {
            s = d_arr_a[i] + d_arr_b[i];
        }

        // Умножение doublestart);
        for (size_t i = 0; i < N; ++i) {
            s = d_arr_a[i] * d_arr_b[i];
        }
    }
}

void run_test_double_asm(double *res_time_s, double *res_time_m, double *f_arr_a, double *f_arr_b, size_t test_count) {
    double res_mul = 0, res_sum = 0;
    volatile double s;

    struct timespec start, end;
    for (size_t c = 0; c < test_count; ++c) {
        
        
        // Сложение float
        clock_gettime(CLOCK_MONOTONIC, &start);
        for (size_t i = 0; i < N; ++i) {
            s = f_arr_a[i] + f_arr_b[i];
        }
        clock_gettime(CLOCK_MONOTONIC, &end);
        res_sum += (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);


        // Умножение float
        clock_gettime(CLOCK_MONOTONIC, &start);
        for (size_t i = 0; i < N; ++i) {
            s = f_arr_a[i] * f_arr_b[i];
        }
        clock_gettime(CLOCK_MONOTONIC, &end);
        res_mul += (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
    }

    *res_time_s = res_sum / test_count / N;
    *res_time_m = res_mul / test_count / N;
}


static double d_arr_a[N];
static double d_arr_b[N];
static float f_arr_a[N];
static float f_arr_b[N];

int main() {
    srand(time(NULL));
    generate_arr(d_arr_a, f_arr_a);
    generate_arr(d_arr_b, f_arr_b);


    double f_sum_time, f_mul_time;
    double d_sum_time, d_mul_time;

    pre_test_float_asm(f_arr_a, f_arr_b, TEST_COUNT);
    run_test_float_asm(&f_sum_time, &f_mul_time, f_arr_a, f_arr_b, TEST_COUNT);
    printf(
        "=== float ===\n"
        "sum: %lf\n"
        "mul: %lf\n",
        f_sum_time, f_mul_time
    );

    pre_test_double_asm(d_arr_a, d_arr_b, TEST_COUNT);
    run_test_double_asm(&d_sum_time, &d_mul_time, d_arr_a, d_arr_b, TEST_COUNT);
    printf(
        "=== double ===\n"
        "sum: %lf\n"
        "mul: %lf\n",
        d_sum_time, d_mul_time
    );
    
}