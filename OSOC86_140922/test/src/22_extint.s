.code16
start:

movw $256, %sp
movw $0x4000, (32)
movw $0xf000, (34)

sti

lcall $0xf000, $0x2000

nop
nop
movw $0x9abc, (4)
movw $0xdef0, (6)
nop
nop

hlt

.org 0x2000
func:
movw $0xa5b5, (8)
movw $0xc3c3, (10)
lret $10
hlt

.org 0x4000
movw $0x1234, (0)
movw $0x5678, (2)
iret

hlt 

.org 65520
jmp start
.org 65535
.byte 0xff
