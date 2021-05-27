.code16
start:
movw $0xf100, %bx
movw %bx, %es
movw $0x0010, %bx


es les 2(%bx), %bx
es les 3(%bx), %bx
es les 4(%bx), %bx
es les 5(%bx), %bx

movw %ax, (0)
movw %cx, (2)
movw %dx, (4)
movw %bx, (6)

hlt


.org 0x1012
.word 0x0020
.word 0xf200

.org 0x1022
.word 0xc3c3
.word 0xa5a5

.org 0x2023
.word 0x0030
.word 0xf300

.org 0x3034
.word 0x0040
.word 0xf400

.org 0x4045
.word 0x0050
.word 0xf500


.org 65520
jmp start
.org 65535
.byte 0xff
