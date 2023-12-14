
.proc NMI
	phaxy

	; Palette
	bit PPUSTATUS
	ldx #$3f
	stx PPUADDR
	ldx #$00
	stx PPUADDR
	DO
		lda palette_1,x
		sta PPUDATA
	FOR X, NE, #$20, inx

	; VRAM buffer
	ldx vram_buffer_index
	IF NE
		ldx #0
		DO
			lda vram_buffer_adr_hi,x
			sta PPUADDR
			lda vram_buffer_adr_lo,x
			sta PPUADDR
			lda vram_buffer_data,x
			sta PPUDATA
		FOR X, NE, z:vram_buffer_index, inx
		ldx #0
		stx z:vram_buffer_index
	END_IF

	; Update scrolling
	lda scroll_nt
	ora ppuctrl_copy
	sta PPUCTRL
	lda scroll_x
	sta PPUSCROLL
	lda scroll_y
	sta PPUSCROLL

	; Controller reading before OAM DMA
	lda controller_1_current
	sta controller_1_old
	lda controller_2_current
	sta controller_2_old

	; OAM DMA
	lda #$00
	sta OAMADDR
	lda #$02
	sta OAMDMA

	; Controller reading after OAM DMA
	ldx #1								; get put
	stx controller_1_current			; get put get
	stx CTRL1							; put get put get
	dex									; put get
	stx CTRL1							; put get put get
	ReadLoop:
		lda CTRL2_FRMCNT				; put get put GET
		lsr								; put get
		rol controller_2_current,x		; put get put get put get
		lda CTRL1						; put get put GET
		lsr								; put get
		rol controller_1_current		; put get put get put
		bcc ReadLoop					; get put get
	; End of reading controller data, don't need to worry about DMA cycles
	lda controller_1_old
	eor #$ff
	and controller_1_current
	sta controller_1_new
	lda controller_2_old
	eor #$ff
	and controller_2_current
	sta controller_2_new


	lda #1
	sta nmi_done
	plaxy
	rti
.endproc


.proc WaitForNMI
	inc nmi_ready
	lda nmi_done
	beq *-2
	dec nmi_done
	dec nmi_ready
	rts
.endproc
