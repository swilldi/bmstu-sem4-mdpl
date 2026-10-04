# Сборка двух версий: 32-разрядная и 64-разрядная.
# Требуется: gcc (с поддержкой multilib для 32-бит), nasm.
# Под Ubuntu/Debian: sudo apt install gcc-multilib nasm

CC      := gcc
NASM    := nasm
CFLAGS  := -Wall -Wextra -O1
LDFLAGS :=

.PHONY: all clean run run32 run64

all: main_32 main_64

# ---------- 32-bit ----------
str_copy32.o: str_copy32.asm
	$(NASM) -f elf32 $< -o $@

main32.o: main.c
	$(CC) $(CFLAGS) -m32 -c $< -o $@

main_32: main32.o str_copy32.o
	$(CC) -m32 $^ -o $@

# ---------- 64-bit ----------
str_copy64.o: str_copy64.asm
	$(NASM) -f elf64 $< -o $@

main64.o: main.c
	$(CC) $(CFLAGS) -m64 -c $< -o $@

main_64: main64.o str_copy64.o
	$(CC) -m64 $^ -o $@

run: run32 run64
run32: main_32
	./main_32
run64: main_64
	./main_64

clean:
	rm -f *.o main_32 main_64
