
ColdResetCheckData:
	.byte "COLD RESET BYTES"

.proc Reset
	sei
	cld

	ldx #$40
	stx CTRL2_FRMCNT

	lxa #0
	stx PPUCTRL
	stx PPUMASK

	dex
	txs

	bit PPUSTATUS
	bit PPUSTATUS
	bpl *-3

	lxa #0
	DO
		sta $00,x
		sta $0100,x
		sta $0200,x
		sta $0300,x
		sta $0400,x
		sta $0500,x
		sta $0600,x
		sta $0700,x
	FOR X, NE, #0, inx

	inc rng_data

	bit PPUSTATUS
	bpl *-3

	lda #$20
	sta PPUADDR
	lxa #0
	sta PPUADDR
	ldy #$08
	DO
		DO
			sta PPUDATA
		FOR X, NE, #0, inx
	FOR Y, PL, #$ff, dey
	
.endproc

