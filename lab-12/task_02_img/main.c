#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#define picture_data_t unsigned char
#define picture_t unsigned char*

void avgColor(picture_data_t res[], picture_data_t *data, int w, int h) {
    long avg[] = { 0, 0, 0, 0 };

    size_t i = 0;
    for (; i + 64 <= w * h * 4; i += 4 * 16) {
        asm volatile(
            "ld4 { v0.16b, v1.16b, v2.16b, v3.16b }, [%[data]]\n"
            "uaddlv h0, v0.16b\n"
            "uaddlv h1, v1.16b\n"
            "uaddlv h2, v2.16b\n"
            "uaddlv h3, v3.16b\n"

            "umov w4, v0.h[0]\n"
            "umov w5, v1.h[0]\n"
            "umov w6, v2.h[0]\n"
            "umov w7, v3.h[0]\n"

            "ldr x9, [%[avg]]\n"
            "add x9, x9, x4\n"
            "str x9, [%[avg]]\n"

            "ldr x9, [%[avg], #8]\n"
            "add x9, x9, x5\n"
            "str x9, [%[avg], #8]\n"

            "ldr x9, [%[avg], #16]\n"
            "add x9, x9, x6\n"
            "str x9, [%[avg], #16]\n"
            
            "ldr x9, [%[avg], #24]\n"
            "add x9, x9, x7\n"
            "str x9, [%[avg], #24]\n"
            : 
            : [data] "r"(data + i), [avg] "r"(avg)
            : "memory", "v0", "v1", "v2", "v3", "x9", "w4", "w5", "w6", "w7"
        );
    }

    for (; i < w * h * 4; i += 4) {
        asm volatile (
            "ldrb w4, [%[data], #0]\n"
            "ldrb w5, [%[data], #1]\n"
            "ldrb w6, [%[data], #2]\n"
            "ldrb w7, [%[data], #3]\n"

            "ldr x9, [%[avg]]\n"
            "add x9, x9, x4\n"
            "str x9, [%[avg]]\n"

            "ldr x9, [%[avg], #8]\n"
            "add x9, x9, x5\n"
            "str x9, [%[avg], #8]\n"

            "ldr x9, [%[avg], #16]\n"
            "add x9, x9, x6\n"
            "str x9, [%[avg], #16]\n"
            
            "ldr x9, [%[avg], #24]\n"
            "add x9, x9, x7\n"
            "str x9, [%[avg], #24]\n"
            : 
            : [data] "r"(data + i), [avg] "r"(avg)
            : "memory", "x9", "w4", "w5", "w6", "w7"
        );
    }

    for (size_t i = 0; i < 4; ++i) {
        asm volatile (
            "ldr x0, [%[color]]\n"
            "udiv x0, x0, %[pixels]\n"
            "str x0, [%[color]]\n"
            :
            : [color] "r"(avg + i), [pixels] "r"((long)(w * h))
            : "memory", "x0", "d0", "d1"
        );
    }

    for (size_t i = 0; i < 4; ++i)
        res[i] = (picture_data_t)avg[i];
}

// void setColor(picture_data_t *data, int w, int h, picture_data_t color[]) {
//     for (size_t i = 0; i < w * h * 4; i += 4) {
//         data[i] = color[0];
//         data[i + 1] = color[1];
//         data[i + 2] = color[2];
//         data[i + 3] = color[3];
//     }
// }

void setColor(picture_data_t *data, int w, int h, picture_data_t color[], int epsColor) {
    for (size_t i = 0; i < w * h * 4; i += 4) {
        asm volatile (
            "ldrb w0, [%[pixel], #0]\n"
            "ldrb w1, [%[pixel], #1]\n"
            "ldrb w2, [%[pixel], #2]\n"
            "ldrb w3, [%[pixel], #3]\n"
            
            "ldrb w4, [%[avg], #0]\n"
            "ldrb w5, [%[avg], #1]\n"
            "ldrb w6, [%[avg], #2]\n"
            "ldrb w7, [%[avg], #3]\n"

            // red
            "subs w0, w0, w4\n"
            "cneg w0, w0, mi\n"
            "cmp w0, %w[eps]\n"
            "b.gt 1f\n"

            // green
            "subs w1, w1, w5\n"
            "cneg w1, w1, mi\n"
            "cmp w1, %w[eps]\n"
            "b.gt 1f\n"

            // blue
            "subs w2, w2, w6\n"
            "cneg w2, w2, mi\n"
            "cmp w2, %w[eps]\n"
            "b.gt 1f\n"

            // alpha
            "subs w3, w3, w7\n"
            "cneg w3, w3, mi\n"
            "cmp w3, %w[eps]\n"
            "b.gt 1f\n"

            // установка цвета
            "mov w0, #255\n"
            "mov w1, #0\n"
            "mov w2, #0\n"
            "mov w3, #255\n"

            // сохранение
            "strb w0, [%[pixel]]\n"
            "strb w1, [%[pixel], #1]\n"
            "strb w2, [%[pixel], #2]\n"
            "strb w3, [%[pixel], #3]\n"

            "1:\n"
            :
            : [pixel] "r"(data + i), [avg] "r"(color), [eps] "r"(epsColor)
            : "memory", "w0", "w1", "w2", "w3", "w4", "w5", "w6", "w7"
        );
    }
}



int main(int argc, char** argv) {
    int w, h, channels;
    int epsColor = argc > 2 ? atoi(argv[2]) : 10;
    
    picture_data_t *data = stbi_load(argv[1], &w, &h, &channels, 4);
    if (!data) {
        printf("Load image error\n");
        return 1;
    }

    printf("size: %d x %d\n", w, h);

    
    picture_data_t res[4];
    avgColor(res, data, h, w);
    setColor(data, w, h, res, epsColor);
    printf("%d %d %d %d\n", res[0], res[1], res[2], res[3]);

    stbi_write_png("result.png", w, h, 4, data, w * 4);

    stbi_image_free(data);
    return 0;
}