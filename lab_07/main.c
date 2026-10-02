#include <stdio.h>
#include <string.h>
#include <stddef.h>

extern void my_strcpy(char *dst, const char *src, size_t len);

size_t my_strlen(const char *s)
{
    size_t len;
#ifdef __x86_64__
    __asm__ volatile (
        ".intel_syntax noprefix\n"
        "mov rdi, %1\n"
        "xor eax, eax\n"
        "mov rcx, -1\n"
        "cld\n"
        "repne scasb\n"
        "not rcx\n"
        "dec rcx\n"
        "mov %0, rcx\n"
        ".att_syntax prefix\n"
        : "=r" (len)
        : "r" (s)
        : "rax", "rcx", "rdi", "cc"
    );
#else
    __asm__ volatile (
        ".intel_syntax noprefix\n"
        "mov edi, %1\n"
        "xor eax, eax\n"
        "mov ecx, -1\n"
        "cld\n"
        "repne scasb\n"
        "not ecx\n"
        "dec ecx\n"
        "mov %0, ecx\n"
        ".att_syntax prefix\n"
        : "=r" (len)
        : "r" (s)
        : "eax", "ecx", "edi", "cc"
    );
#endif
    return len;
}

void show(const char *label, const char *buf, size_t n)
{
    printf("  %s = \"", label);
    for (size_t i = 0; i < n; i++) {
        unsigned char c = (unsigned char)buf[i];
        if (c >= 0x20 && c < 0x7F) putchar(c);
        else printf("\\x%02X", c);
    }
    printf("\"\n");
}

int report(const char *name, int ok)
{
    printf("[%s] %s\n", ok ? "OK  " : "FAIL", name);
    return ok;
}

int my_strlen_WhenStringIsEmpty_ReturnsZero(void)
{
    /* Arrange */
    const char *src = "";
    /* Act */
    size_t actual = my_strlen(src);
    /* Assert */
    return report(__func__, actual == 0);
}

int my_strlen_WhenStringHasOneChar_ReturnsOne(void)
{
    /* Arrange */
    const char *src = "a";
    /* Act */
    size_t actual = my_strlen(src);
    /* Assert */
    return report(__func__, actual == 1);
}

int my_strlen_WhenStringIsAscii_ReturnsLibcLength(void)
{
    /* Arrange */
    const char *src = "Hello, world!";
    size_t expected = strlen(src);
    /* Act */
    size_t actual = my_strlen(src);
    /* Assert */
    return report(__func__, actual == expected);
}

int my_strlen_WhenStringIsSixteenChars_ReturnsSixteen(void)
{
    /* Arrange */
    const char *src = "0123456789abcdef";
    /* Act */
    size_t actual = my_strlen(src);
    /* Assert */
    return report(__func__, actual == 16);
}

int my_strcpy_WhenBuffersDoNotOverlap_CopiesSourceToDestination(void)
{
    /* Arrange */
    const char *src = "Hello, assembler!";
    char dst[64] = {0};
    size_t n = my_strlen(src) + 1;
    /* Act */
    my_strcpy(dst, src, n);
    /* Assert */
    return report(__func__, strcmp(dst, src) == 0);
}

int my_strcpy_WhenDstBeforeSrcAndOverlap_ShiftsBytesLeft(void)
{
    /* Arrange: dst < src, перекрытие — сдвиг строки влево на 2 байта */
    char buf[16] = "ABCDEFGHIJ";
    const char expected[] = {'C','D','E','F','G','H','I','J','I','J','\0'};
    /* Act */
    my_strcpy(buf + 0, buf + 2, 8);
    /* Assert */
    int ok = (memcmp(buf, expected, 10) == 0);
    show("  buf", buf, 10);
    return report(__func__, ok);
}

int my_strcpy_WhenDstAfterSrcAndOverlap_ShiftsBytesRight(void)
{
    /* Arrange: dst > src, перекрытие — сдвиг строки вправо на 2 байта */
    char buf[16] = "ABCDEFGHIJ";
    const char expected[] = {'A','B','A','B','C','D','E','F','G','H','\0'};
    /* Act */
    my_strcpy(buf + 2, buf + 0, 8);
    /* Assert */
    int ok = (memcmp(buf, expected, 10) == 0);
    show("  buf", buf, 10);
    return report(__func__, ok);
}

int main(void)
{
#ifdef __x86_64__
    printf("=== 64-bit build ===\n");
#else
    printf("=== 32-bit build ===\n");
#endif

    int passed = 0, total = 7;

    passed += my_strlen_WhenStringIsEmpty_ReturnsZero();
    passed += my_strlen_WhenStringHasOneChar_ReturnsOne();
    passed += my_strlen_WhenStringIsAscii_ReturnsLibcLength();
    passed += my_strlen_WhenStringIsSixteenChars_ReturnsSixteen();

    passed += my_strcpy_WhenBuffersDoNotOverlap_CopiesSourceToDestination();
    passed += my_strcpy_WhenDstBeforeSrcAndOverlap_ShiftsBytesLeft();
    passed += my_strcpy_WhenDstAfterSrcAndOverlap_ShiftsBytesRight();

    printf("\n%d/%d passed\n", passed, total);
    return passed == total ? 0 : 1;
}
