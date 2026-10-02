MAKEFLAGS += -s
.PHONY: clean, run, clear_run

run: app.exe
	./app.exe

clear_run: run
	$(MAKE) clean

app.exe: main.o
	gcc main.c -o app.exe

clean:
	rm -f *.out *.exe *.o