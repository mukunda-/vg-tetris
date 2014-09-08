
REM SET GAMEDIR TO BUILD.
REM SET GAMEDIR=C:\Steam\steamapps\common\Counter-Strike Global Offensive\csgo
SET VGNAME=tetris

@echo converting graphics magically....

mkdir blockcell
mkdir gfx_128_8
mkdir gfx_16_16
mkdir gfx_32_32
mkdir gfx_bg1
mkdir gfx_bg2
mkdir produce
 
del gfx_128_8\* /Q
del gfx_16_16\* /Q
del gfx_32_32\* /Q
del gfx_bg1\* /Q
del gfx_bg2\* /Q
del produce\* /Q

call process blockcell 16 32
convert empty_32_32.png -crop 32x32 gfx_32_32/sprite_0_%%03d.png
convert tetrominoes.tga -crop 32x32 -transparent #000000 gfx_32_32/sprite_1_%%03d.tga
convert ghosts.png -crop 32x32 gfx_32_32/sprite_2_%%03d.png
convert tetriminos_small.png -crop 32x32 -transparent #000000 gfx_32_32/sprite_3_%%03d.png
convert font.tga -crop 32x32 -transparent #000000 gfx_32_32/sprite_4_%%03d.tga
convert reflex.tga -crop 32x32 gfx_32_32/sprite_5_%%03d.tga
convert fieldoverlays.tga -crop 32x32 gfx_32_32/sprite_6_%%03d.tga
convert titleoptions.tga -crop 32x32 gfx_32_32/sprite_7_%%03d.tga
convert selector.png -crop 32x32 gfx_32_32/sprite_8_%%03d.png
call process gfx_32_32 32 32 -x
convert lines.png -crop 128x8 -transparent #000000 gfx_128_8/sprite_1_%%03d.png
call process gfx_128_8 128 8
convert empty_16_16.png -crop 16x16 gfx_16_16/sprite_0_%%03d.png
convert tetriminos_small.png -crop 16x16 -transparent #000000 gfx_16_16/sprite_1_%%03d.png
call process gfx_16_16 16 16
convert bgtiles1.png -crop 16x16 gfx_bg1/sprite_0_%%03d.png
call process gfx_bg1 16 16
convert bgtiles2.png -crop 16x16 gfx_bg2/sprite_0_%%03d.png
call process gfx_bg2 16 16

pause
