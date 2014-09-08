
@echo Processing: %1 ......


@echo -----------------------------------
@echo creating vtf...
@echo -----------------------------------
vtfcmd2 -multi -silent -folder %1 -output produce/%1.vtf -nomipmaps -format "RGBA8888" -flag "POINTSAMPLE" -flag "CLAMPS" -flag "CLAMPT" -flag "NOMIP" -flag "NOLOD"
@echo -----------------------------------
@echo generating QC...
@echo -----------------------------------
genqc.py -g %VGNAME% -m %1 -s compile.smd -o compile.qc
@echo -----------------------------------
@echo generating SMD...
@echo -----------------------------------
gensmd.py --width=%2 --height=%3 --texture=%1 --output=compile.smd
rem gensmd.py --width=1 --height=1 --texture=%1 --output=compile.smd
@echo -----------------------------------
@echo compiling...
@echo -----------------------------------
"%GAMEDIR%\..\bin\studiomdl" -game "%GAMEDIR%" compile.qc
@echo -----------------------------------
@echo generating material...
genvmt.py -g %VGNAME% -t %1 -o produce\%1.vmt %4
@echo -----------------------------------
@echo copying material...
@echo -----------------------------------
copy produce\%1.vtf "%GAMEDIR%\materials\videogames\%VGNAME%\" /Y
copy produce\%1.vmt "%GAMEDIR%\materials\videogames\%VGNAME%\" /Y
@echo -----------------------------------
@echo done.
@echo -----------------------------------
