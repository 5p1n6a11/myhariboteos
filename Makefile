TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/haribote/

MAKE	 = $(TOOLPATH)make -r
NASK	 = $(TOOLPATH)nask
CC1	 = $(TOOLPATH)gocc1 -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask -a
OBJ2BIM	 = $(TOOLPATH)obj2bim
MAKEFONT = $(TOOLPATH)makefont
BIN2OBJ  = $(TOOLPATH)bin2obj
BIM2HRB	 = $(TOOLPATH)bim2hrb
RULEFILE = $(TOOLPATH)haribote/haribote.rul
EDIMG	 = $(TOOLPATH)edimg
IMGTOL	 = $(TOOLPATH)imgtol
HARITOL	 = $(TOOLPATH)haritol

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

ipl10.bin : ipl10.nas Makefile
	$(NASK) ipl10.nas ipl10.bin ipl10.lst

asmhead.bin : asmhead.nas Makefile
	$(NASK) asmhead.nas asmhead.bin asmhead.lst

bootpack.gas : bootpack.c Makefile
	$(CC1) -o bootpack.gas bootpack.c

bootpack.nas : bootpack.gas Makefile
	$(GAS2NASK) bootpack.gas bootpack.nas

bootpack.obj : bootpack.nas Makefile
	$(NASK) bootpack.nas bootpack.obj bootpack.lst

naskfunc.obj : naskfunc.nas Makefile
	$(NASK) naskfunc.nas naskfunc.obj naskfunc.lst

hankaku.bin : hankaku.txt Makefile
	$(MAKEFONT) hankaku.txt hankaku.bin

hankaku.obj : hankaku.bin Makefile
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

graphic.gas : graphic.c Makefile
	$(CC1) -o graphic.gas graphic.c

graphic.nas : graphic.gas Makefile
	$(GAS2NASK) graphic.gas graphic.nas

graphic.obj : graphic.nas Makefile
	$(NASK) graphic.nas graphic.obj graphic.lst

dsctbl.gas : dsctbl.c Makefile
	$(CC1) -o dsctbl.gas dsctbl.c

dsctbl.nas : dsctbl.gas Makefile
	$(GAS2NASK) dsctbl.gas dsctbl.nas

dsctbl.obj : dsctbl.nas Makefile
	$(NASK) dsctbl.nas dsctbl.obj dsctbl.lst

bootpack.bim : bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj
# 3MB+64KB=3136KB

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

haribote.sys : asmhead.bin bootpack.hrb Makefile
	$(HARITOL) concat haribote.sys asmhead.bin bootpack.hrb

haribote.img : ipl10.bin haribote.sys Makefile
	$(EDIMG) imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl10.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

# コマンド

img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	$(HARITOL) concat ../z_tools/qemu/fdimage0.bin haribote.img
	$(MAKE) -C ../z_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: haribote.img

clean :
	-$(HARITOL) remove *.bin
	-$(HARITOL) remove *.lst
	-$(HARITOL) remove *.gas
	-$(HARITOL) remove *.obj
	-$(HARITOL) remove bootpack.nas
	-$(HARITOL) remove graphic.nas
	-$(HARITOL) remove dsctbl.nas
	-$(HARITOL) remove bootpack.map
	-$(HARITOL) remove bootpack.bim
	-$(HARITOL) remove bootpack.hrb
	-$(HARITOL) remove haribote.sys

src_only :
	$(MAKE) clean
	-$(HARITOL) remove haribote.img

