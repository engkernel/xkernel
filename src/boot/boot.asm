ORG 0x7c00
[BITS 16]

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; jump over the disk format information BPB and EBPB
_start:
	jmp short start
	nop

times 33 db 0 
; end of jump

start:
	jmp 0:stage2

stage2:
	; setup segments and stack
	cli ; disable interrupts
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

	; enter protected mode
	lgdt [gdt]
	mov eax, cr0  ; set 0 in cr0 to enter protected mode
	or  eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:load32

; GDT 
gdt_start:
; null descriptor
gdt_null:
	dd 0x00 
	dd 0x00

; code segment at 0x8
gdt_code:
	dw 0xffff	; segment length
	dw 0		; limit low
	db 0		; base middle
	db 0x9a		; access 
	db 0xc  	; granularity
	db 0		; base high

; data segment at 0x10
gdt_data:
	dw 0xffff	; segment length
	dw 0		; limit low
	db 0		; base middle
	db 0x92		; access 
	db 0xc		; granularity
	db 0		; base high
gdt_end:

; gdt
gdt:
	dw gdt_start - gdt_end - 1
	dd gdt_start

[BITS 32]
load32:
        mov eax, 1
        mov ecx, 100
        mov edi, 0x0100000
        call ata_lba_read
        jmp CODE_SEG:0x0100000

ata_lba_read:
        mov ebx, eax    ; Backup the LBA
        ; Send the highest 8 bits of the lba to hard disk controller
        shr eax, 24
        or eax, 0xE0 ; Select the master drive
        mov dx, 0x1F6
        out dx, al
        ; Finished sending the highest 8 bits of the lba

        ; Send the total sectors to read
        mov eax, ecx
        mov dx, 0x1F2
        out dx, al
        ; Finished sending the total sectors to read

        ; Send more bits of the LBA
        mov eax, ebx ; Restore the backup LBA
        mov dx, 0x1F3
        out dx, al
        ; Finished sending more bits of the LBA

        ; Send more bits of LBA
        mov dx, 0x1F4
        mov eax, ebx    ; Restor the backup LBA
        shr eax, 8
        out dx, al
        ; Finished sending more bits of the LBA

        ; Send upper 16 bits of the LBA
        mov dx, 0x1F5
        mov eax, ebx ; Restore the backup LBA
        shr eax, 16
        out dx, al
        ; Finished sending upper 16 bits of the LBA

        mov dx, 0x1f7
        mov al, 0x20
        out dx, al

        ; Read all sectors into memory
.next_sector:
        push ecx

; Checing if we need to read
.try_again:
        mov dx, 0x1f7
        in al, dx
        test al, 8
        jz .try_again

; We need to read 256 words at a time
        mov ecx, 256
        mov dx, 0x1F0
        rep insw
        pop ecx
        loop .next_sector
        ; End of reading sectors into memory
        ret


times 510-($-$$) db 0
dw 0xAA55
