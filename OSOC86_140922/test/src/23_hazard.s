.code16
start:

movw $256, %sp
nop

movb $0x01, %al	#pipelined no hazards no stalls
movb $0x02, %cl
movb $0x04, %dl
movb $0x08, %bl
movw $0xAA55, %si
movw $0x55AA, %di
movb $0x10, %ah
movb $0x20, %ch
movb $0x40, %dh
movb $0x80, %bh
addb %al, %bh	#hazard
addb %cl, %ah
addb %dl, %ch
addb %bl, %dh

movw %ax, (0)
movw %cx, (2)
movw %dx, (4)
movw %bx, (6)
movw %si, (8)
movw %di, (10)

movw $0xABCD, %bx
movw $0x09EF, %dx
movw $0x5678, %cx
movw $0x1234, %ax
addb (0), %al
movw $0xBC3D, %bx
movw $0x9E2F, %dx
movw $0x6718, %cx
movw %ax, %si
addb (1), %cl
addb (2), %al
movw $0xC3D1, %bx
movw $0xE2F2, %dx
movw $0xC3D3, %bx
movw $0xE2F4, %dx
movw %ax, %di
movw %si, (12)
movw %di, (14)
movw %cx, (16)


movb $0xc7, %al
movb $0x00, %ah
outb %al, $0xb7
movb $0x00, %al
movb $0x00, %ah
movb $0x00, %cl
movb $0x00, %ch
movw $0x0000, %bx
movw $0x00b7, %dx
inb  %dx, %al
movb %al, %bl
movw %ax, (18)
movw %dx, (20)
movw %bx, (22)

movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x11, %dl
movb $0x00, %cl
addb (0), %dl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb %dl, (24)

movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x11, %dl
addb (0), %dl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb %dl, (25)

movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb (0), %bl
addb %bl, %dl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb %dl, (26)

movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb (0), %bl
movb $0x00, %cl
addb %bl, %dl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb $0x00, %cl
movb %dl, (27)



hlt 

.org 65520
jmp start
.org 65535
.byte 0xff
