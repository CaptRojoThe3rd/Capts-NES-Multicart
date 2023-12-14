
.proc Connect4

	; Global vars are $00-$2f

	game_location			= $30
	game_type				= $31
	current_turn			= $32
	

	.proc Init
		lda #PPUCtrl_OffNormal
		sta PPUCTRL
		lda #PPUMask_OffNormal
		sta PPUMASK

		lda #$20
		sta PPUADDR
		lda #0
		sta PPUADDR
		ldx #0
		ldy #$08
		DO
			DO
				sta PPUDATA
			FOR X, NE, #0, inx
		FOR Y, NE, #0, dey

		lda #$21
		sta PPUADDR
		sta temp+1
		lda #$09
		sta PPUADDR
		sta temp
		ldx #14
		ldy #0
		:
			lda Connect4Board,y
			sta PPUDATA
			iny
			dex
			bne :-
			ldx #14
			lda temp
			clc
			adc #32
			sta temp
			lda #0
			adc temp+1
			sta temp+1
			sta PPUADDR
			lda temp
			sta PPUADDR
			cpy #168
			bne :-


		rts
	.endproc

	.proc Update
		rts
	.endproc


	Connect4Palette:
		.byte $1c, $1c, $1c, $30
		.byte $1c, $02, $11, $30
		.byte $1c, $06, $16, $30
		.byte $0f, $1c, $2d, $30

		.byte $1c, $02, $11, $12
		.byte $1c, $06, $16, $05
		.byte $1c, $17, $27, $37
		.byte $1c, $1c, $1c, $30

	Connect4Board:
		.byte $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11
		.byte $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13
		.byte $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11
		.byte $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13
		.byte $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11
		.byte $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13
		.byte $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11
		.byte $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13
		.byte $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11
		.byte $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13
		.byte $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11, $10, $11
		.byte $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13, $12, $13

.endproc
