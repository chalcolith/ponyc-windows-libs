@echo off
echo Cleaning up Windows libraries for Pony.
del /q lib\*.lib
del /q lib\*.exp
del /q lib\*.pdb
del /q lib\*.dll
rmdir /s /q src
