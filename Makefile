TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/haribote/

MAKE	 = $(TOOLPATH)make -r
NASK	 = $(TOOLPATH)nask
CC1	 = $(TOOLPATH)gocc1 -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask -a
OBJ2BIM	 = $(TOOLPATH)obj2bim
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

bootpack.bim : bootpack.obj naskfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj naskfunc.obj
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
	-$(HARITOL) remove bootpack.map
	-$(HARITOL) remove bootpack.bim
	-$(HARITOL) remove bootpack.hrb
	-$(HARITOL) remove haribote.sys

src_only :
	$(MAKE) clean
	-$(HARITOL) remove haribote.img
