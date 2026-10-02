@echo off
set name=%1
masm %name%.asm
link %name%.obj