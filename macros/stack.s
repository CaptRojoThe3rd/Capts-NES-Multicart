.macro phax
	pha
	txa
	pha
.endmacro


.macro plax
	pla
	tax
	pla
.endmacro


.macro phay
	pha
	tya
	pha
.endmacro


.macro play
	pla
	tay
	pla
.endmacro


.macro phaxy
	pha
	txa
	pha
	tya
	pha
.endmacro


.macro plaxy
	pla
	tay
	pla
	tax
	pla
.endmacro


.macro phaxyp
	pha
	txa
	pha
	tya
	pha
	php
.endmacro


.macro plaxyp
	plp
	pla
	tay
	pla
	tax
	pla
.endmacro


.macro ins
	tsx
	inx
	txs
.endmacro


.macro des
	tsx
	dex
	txs
.endmacro


; Indirect JSR
; jsi
.macro jsi addr, returnAddr
	; No specified return address - jump ahead of the instructions
	.ifblank returnAddr
		lda #>(*+8)
		pha
		lda #<(*+5)
		pha
	; Specified return address - jump to this address
	.else
		lda #>(returnAddr-1)
		pha
		lda #<(returnAddr-1)
		pha
	.endif

	; Jump
	jmp (addr)
.endmacro


