@echo off

set path=%path%;..\bin\
set CC65_HOME=..\

set mainasm="main"
set mainc="game"
set romname=Capts_NES_Multicart

::c:\cc65\bin\cc65 -Oirs %mainc%.c --add-source
c:\cc65\bin\ca65 %mainasm%.s --cpu 6502x
::c:\cc65\bin\ca65 %mainc%.s

c:\cc65\bin\ld65 -C config/nrom_32_8.cfg -o %romname%.nes main.o

del *.o

move /Y %romname%.* build\ 
::move /Y %mainc%.s build\

build\%romname%.nes
