CC = gcc
CFLAGS = -O0 -m32

all: build_x87 build_sse build_asm
	@echo "================"
	./main_x87
	@echo "================"
	./main_sse
	@echo "================"
	./main_asm
	@echo "================"

# main.c с x87
build_x87.exe: main.c
	$(CC) $(CFLAGS) -m80387 main.c -o main_x87.exe

# main.c с SSE
build_sse.exe: main.c
	$(CC) $(CFLAGS) -mno-80387 -msse2 -mfpmath=sse main.c -o main_sse.exe

# main_asm.c с x87
build_asm.exe: main_asm.c
	$(CC) $(CFLAGS) -m80387 main_asm.c -o main_asm.exe

clean:
	rm -f *.exe