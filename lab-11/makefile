
app.exe: main.o
	$(CC) main.o -o app.exe

main.o: main.c
	$(CC) -c -masm=intel -mavx2 -mfma -Wall main.c

clean:
	rm main.o

