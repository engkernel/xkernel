ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
	jmp short start
	nop
; fill zero 33 byte for BPB
times 33 db 0

start:
	jmp 0:step2
step2:
	cli 
	mov ax, 0x00
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00	
	sti
.load_protected:
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:load32

; gdt descriptor
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0

; offset 0x8
gdt_code:
	dw 0xffff ; gdt_code len
	dw 0 	  ; base 0-15
	db 0      ; base 16-23
	db 0x9a   ; access byte
	db 11001111b ; high 4 bit and low 4 bit flag
	db 0
gdt_data:
	dw 0xffff ; gdt_code len
	dw 0 	  ; base 0-15
	db 0      ; base 16-23
	db 0x92   ; access byte
	db 11001111b ; high 4 bit and low 4 bit flag
	db 0

gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

[BITS 32]
load32:
	mov eax, 1
	mov ecx, 100
	mov edi, 0x0100000
	call ata_lba_read
	jmp CODE_SEG:0x0100000

ata_lba_read:
	mov ebx, eax
	
	mov dx, 0x1F6
	shr eax, 24
	or eax, 0xE0
	out dx, al

	mov eax, ecx
	mov dx, 0x1F2
	out dx, al

	mov dx, 0x1F3
	mov eax, ebx
	out dx, al

	mov dx, 0x1F4
	mov eax, ebx
	shr eax, 8
	out dx, al

	mov dx, 0x1F5
	mov eax, ebx
	shr eax, 16
	out dx, al

	mov dx, 0x1F7
	mov al, 0x20
	out dx, al
.next_sector:
	push ecx

.try_again:
	mov dx, 0x1F7
	in al, dx
	test al, 8
	jz .try_again

	mov ecx, 256
	mov dx, 0x1F0
	rep insw
	pop ecx
	loop .next_sector
	ret

times 510-($-$$) db 0
dw 0xAA55
