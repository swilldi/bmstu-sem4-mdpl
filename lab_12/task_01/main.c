#include <stdio.h>
#include <string.h>
#include <stddef.h>

size_t strlenAsm(char *str)
{
    size_t len;
    asm volatile(
        "mov x0, %[str]\n"
        "mov %[len], xzr\n"
        "ldrb w1, [x0, %[len]]\n"
    "1:\n"
        "cbz w1, 2f\n"
        "add %[len], %[len], #1\n"
        "ldrb w1, [x0, %[len]]\n"
        "b 1b\n"
    "2:"
        : [len] "+r" (len)
        : [str] "r" (str)
        : "cc", "memory", "x0", "x1"
    );
    return len;
}

int report(const char *name, int ok)
{
    printf("[%s] %s\n", ok ? "OK  " : "FAIL", name);
    return ok;
}

int strlenAsm_WhenStringIsEmpty_ReturnsZero(void)
{
    /* Arrange */
    char *src = "";
    /* Act */
    size_t actual = strlenAsm(src);
    /* Assert */
    return report(__func__, actual == 0);
}

int strlenAsm_WhenStringHasOneChar_ReturnsOne(void)
{
    /* Arrange */
    char *src = "a";
    /* Act */
    size_t actual = strlenAsm(src);
    /* Assert */
    return report(__func__, actual == 1);
}

int strlenAsm_WhenStringIsAscii_ReturnsLibcLength(void)
{
    /* Arrange */
    char *src = "Hello, world!";
    size_t expected = strlen(src);
    /* Act */
    size_t actual = strlenAsm(src);
    /* Assert */
    return report(__func__, actual == expected);
}

int strlenAsm_WhenStringHasWhitespace_ReturnsThree(void)
{
    /* Arrange */
    char *src = "\t\n\r";
    /* Act */
    size_t actual = strlenAsm(src);
    /* Assert */
    return report(__func__, actual == 3);
}

int strlenAsm_WhenStringHasDigitsAndLetters_ReturnsLibcLength(void)
{
    /* Arrange */
    char *src = "0123456789abcdef";
    size_t expected = strlen(src);
    /* Act */
    size_t actual = strlenAsm(src);
    /* Assert */
    return report(__func__, actual == expected);
}

int main(void)
{
    int passed = 0, total = 5;

    passed += strlenAsm_WhenStringIsEmpty_ReturnsZero();
    passed += strlenAsm_WhenStringHasOneChar_ReturnsOne();
    passed += strlenAsm_WhenStringIsAscii_ReturnsLibcLength();
    passed += strlenAsm_WhenStringHasWhitespace_ReturnsThree();
    passed += strlenAsm_WhenStringHasDigitsAndLetters_ReturnsLibcLength();

    printf("\n%d/%d passed\n", passed, total);
    return passed == total ? 0 : 1;
}
