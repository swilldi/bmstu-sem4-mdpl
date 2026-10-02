#include <stdio.h>
#include <stdlib.h>

#define OK 0

#define INTEL_ASM __asm(".intel_syntax noprefix\n");

INTEL_ASM __asm("mov eax, 9\n");

typedef float* mtr_t;
typedef float mtr_data_t;

static const int32_t mask_table[16] __attribute__((aligned(32))) = { 
    -1, -1, -1, -1, -1, -1, -1, -1, 
     0,  0,  0,  0,  0,  0,  0,  0
};

void freeMatrix(mtr_t mtr) {
    free(mtr);
}

mtr_t allocMatrix(size_t rowCount, size_t colCount) {
    mtr_t mtr = aligned_alloc(32, sizeof(mtr_data_t) * rowCount * colCount);
    // mtr_t mtr = aligned_alloc(32, sizeof(mtr_data_t) * 8 * 8);
    return mtr;
}

int inputDataMatrix(mtr_t mtr, size_t rowCount, size_t colCount) {
    for (size_t i = 0; i < rowCount * colCount; ++i) {
        if (scanf("%f", &mtr[i]) != 1)
            return 1;
    }
    
    return OK;
}

int inputMatri(mtr_t *mtr, size_t *rowCount, size_t *colCount) {
    int tmp_in;
    
    printf("Entry row count: ");
    if (scanf("%d", &tmp_in) != 1) {
        printf("Invalid input");
        return 1;
    }

    if (tmp_in <= 0) {
        printf("Invalid input");
        return 1;
    }

    *rowCount = tmp_in;

    printf("Entry col count: ");
    if (scanf("%d", &tmp_in) != 1) {
        printf("Invalid input");
        return 1;
    }

    if (tmp_in <= 0) {
        printf("Invalid input");
        return 1;
    }

    *colCount = tmp_in;

    *mtr = allocMatrix(*rowCount, *colCount);
    if (!*mtr) {
        return 1;
    }

    if (inputDataMatrix(*mtr, *rowCount, *colCount) != OK) {
        freeMatrix(*mtr);
        return 1;
    }

    return OK;
}

void printMatrix(mtr_t mtr, size_t rowCount, size_t colCount) {
    for (size_t i = 0; i < rowCount; ++i) {
        for (size_t j = 0; j < colCount; ++j) {
            printf("%f ", mtr[colCount * i + j]);
        }
        printf("\n");
    }
}


mtr_t multMatrixC(mtr_t mtrA, mtr_t mtrB, size_t rowCount, size_t commonCount, size_t colCount) {
    mtr_t mtrRes = allocMatrix(rowCount, colCount);
    if (!mtrRes) {
        return NULL;
    }

    for (size_t i = 0; i < rowCount; ++i) {
        for (size_t j = 0; j < colCount; ++j) {
            mtrRes[i * colCount + j] = 0;
            for (size_t k = 0; k < commonCount; ++k) {
                mtrRes[i * colCount + j] +=  mtrA[i * commonCount + k] * mtrB[k * colCount + j];
            }
        }
    }

    return mtrRes;
}

mtr_t multMatrixAsm(mtr_t mtrA, mtr_t mtrB, size_t rowCount, size_t commonCount, size_t colCount) {
    mtr_t mtrRes = allocMatrix(rowCount, colCount);
    if (!mtrRes) {
        return NULL;
    }

    for (size_t i = 0; i < rowCount * colCount; ++i)
        mtrRes[i] = 0;


    for (size_t i = 0; i < rowCount; ++i) {
        for (size_t k = 0; k < commonCount; ++k) {
            
            float *a_ptr = &mtrA[i * commonCount + k];
            float *b_row = &mtrB[k * colCount];
            float *res_row = &mtrRes[i * colCount];

            size_t blockCount = colCount / 8;
            if (blockCount > 0) {
                // asm volatile (
                //     "vbroadcastss (%[a]), %%ymm0\n"     
                // "1:\n"                                  
                //     "vmovups (%[b]), %%ymm1\n"
                //     "vmovups (%[res]), %%ymm2\n"
                //     "vfmadd231ps %%ymm1, %%ymm0, %%ymm2\n"  // res = a * b + res
                //     "vmovups %%ymm2, (%[res])\n"
                //     "addq $32, %[b]\n"
                //     "addq $32, %[res]\n"
                //     "decq %[n]\n"
                //     "jnz 1b\n"
                //     : [b] "+r"(b_row), [res] "+r"(res_row), [n] "+r"(blockCount)
                //     : [a] "r"(a_ptr)
                //     : "ymm0", "ymm1", "ymm2", "memory", "cc"
                // );

                asm volatile (
                    // ".intel_syntax noprefix\n"
                    "vbroadcastss ymm0, dword ptr %[a]\n"     
                "1:\n"                                  
                    "vmovups ymm1, [%[b]]\n"
                    "vmovups ymm2, [%[res]]\n"
                    "vfmadd231ps ymm2, ymm1, ymm0 \n"  // res = a * b + res
                    "vmovups  [%[res]], ymm2\n"
                    "add %[b], 32\n"
                    "add %[res], 32\n"
                    "dec %[n]\n"
                    "jnz 1b\n"
                    : [b] "+r"(b_row), [res] "+r"(res_row), [n] "+r"(blockCount)
                    : [a] "m"(*a_ptr)
                    : "ymm0", "ymm1", "ymm2", "memory", "cc"
                );
            }
            
            size_t tailLen = colCount % 8;
            if (tailLen > 0) {
                const int32_t *mask_ptr = &mask_table[8 - tailLen];
                asm volatile (
                    // ".intel_syntax noprefix\n"
                    "vmovups ymm3, [%[mask]]\n"
                    "vbroadcastss ymm0, dword ptr %[a]\n"
                    "vmaskmovps ymm1, ymm3, [%[b]]\n" 
                    "vmaskmovps ymm2, ymm3, [%[res]]\n"
                    "vfmadd231ps ymm2, ymm1, ymm0\n"  // res = a * b + res
                    "vmaskmovps [%[res]], ymm3, ymm2\n"
                    :
                    : [a] "m"(*a_ptr), [b] "r"(b_row), [res] "r"(res_row), [mask] "r"(mask_ptr)
                    : "ymm0", "ymm1", "ymm2", "ymm3", "memory"
                );
            }
            
        }
    }

    return mtrRes;
}


int main(void) {
    mtr_t mtrA, mtrB;
    size_t rowCountA, colCountA, rowCountB, colCountB;

    if (inputMatri(&mtrA, &rowCountA, &colCountA) != OK)
        return 1;


    if (inputMatri(&mtrB, &rowCountB, &colCountB) != OK) {
        freeMatrix(mtrA);
        return 1;
    }


    if (colCountA != rowCountB) {
        printf("Not multable matrix");

        freeMatrix(mtrA);
        freeMatrix(mtrB);
        return 1;
    }

    size_t rowCountC = rowCountA, colCountC = colCountB, commonCount = colCountA;

    mtr_t mtrAsm = multMatrixAsm(mtrA, mtrB, rowCountC, commonCount, colCountC);
    if (!mtrAsm) {
        printf("Alloc error");

        freeMatrix(mtrA);
        freeMatrix(mtrB);
        return 1;
    }

    mtr_t mtrC = multMatrixC(mtrA, mtrB, rowCountC, commonCount, colCountC);
    if (!mtrC) {
        printf("Alloc error");

        freeMatrix(mtrA);
        freeMatrix(mtrB);
        freeMatrix(mtrAsm);
        return 1;
    }


    printMatrix(mtrAsm, rowCountC, colCountC);
    printf("\n");
    // printMatrix(mtrC, rowCountC, colCountC);


    freeMatrix(mtrA);
    freeMatrix(mtrB);
    freeMatrix(mtrC);

}
