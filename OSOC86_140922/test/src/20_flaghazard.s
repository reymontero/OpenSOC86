.code16
start:

movw $160, %sp

clc
cld
cli
nop
pushf
jb fin	# jb/jnae/jc

test1:
movw $0xffff, %ax
movw $0x0001, %bx
nop
nop
nop
addw %ax, %bx
jb  ok01	# jb/jnae/jc
jmp test2
ok01:
movw %ax, (0)
movw %bx, (2)
movw $0xA5A5, (4)
pushf

test2:
clc
movw $0xFFEF, %ax
movw $0x0011, %bx
movw $0x1010, %cx
movw $0x0101, %dx
nop
nop
nop
addw %ax, %bx
adcw %cx, %dx
movw %cx, (6)
movw %dx, (8)
pushf


fin:
hlt


.org 65520
jmp start

.org 65535
.byte 0xff
