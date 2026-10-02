ml /c main.asm
ml /c conv.asm
ml /c o_binary.asm
ml /c o_short.asm
ml /c o_pow2.asm
link main.obj conv.obj o_binary.obj o_short.obj o_pow2.obj, program.exe;
del *.obj