GTK_FLAGS := $(shell arch -x86_64 /usr/local/bin/pkg-config --cflags --libs gtk4)

app: main.o popcount.o
	clang -arch x86_64 main.o popcount.o $(GTK_FLAGS) -o app

main.o: main.asm
	nasm -f macho64 main.asm -o main.o

popcount.o: popcount.asm
	nasm -f macho64 popcount.asm -o popcount.o

clean:
	rm -f *.o app