MAKEFLAGS += -s
.PHONY: clean, run, clear_run

app.exe: main.o
	gcc main.c -o app.exe

run: app.exe
	./app.exe

clear_run: run
	$(MAKE) clean


clean:
	rm -f *.out *.exe *.o