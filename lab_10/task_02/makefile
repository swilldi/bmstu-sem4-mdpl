main.exe: main.o
	gcc -m32 -g -no-pie main.o -o main.exe

main.o: main.asm
	nasm -f elf32 -g main.asm -o main.o 

clean:
	rm -rf main.exe main.o
