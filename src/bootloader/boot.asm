[org 0x7c00]

mov ah, 0x00
int 0x16

mov ah, 0x0E
mov bh, 0
int 0x10
jmp $
times 510-($-$$) db 0
db 0x55, 0xaa