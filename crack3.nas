[INSTRSET "i486p"]
[BITS 32]
        MOV     AL,0x34
        OUT     0x43,AL
        MOV     AL,0xff
        OUT     0x40,AL
        MOV     AL,0xff
        OUT     0x40,AL

;   ↑これは以下のプログラムに相当
;   io_out8(PIC_CTRL, 0x34);
;   io_out8(PIC_CTRL, 0xff);
;   io_out8(PIC_CTRL, 0xff);

        MOV     EDX,4
        INT     0x40

