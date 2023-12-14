
.proc Snake

	; Global vars at $00-$2f
	apple_pos			= $30 ; 2 bytes
	snake_head_pos		= $32 ; 2 bytes
	snake_tail_pos		= $34 ; 2 bytes

	inc_tail_length		= $36
	enable_movemnet		= $37
	snake_direction		= $38

	last_snake_head_pos = $39 ; 2 bytes
	last_snake_tail_pos	= $3b ; 2 bytes

	blacklisted_inputs	= $3d
	allow_pause			= $3e

	frame_counter		= $3f
	frame_counter_reset	= $40

	game_paused			= $41
	game_location		= $42

	selected_option		= $43

	screen_data			= $400


	Init:
		; Turn off rendering and NMI
		lda #PPUCtrl_OffNormal
		sta ppuctrl_copy
		sta PPUCTRL
		lda #PPUMask_OffNormal
		sta PPUMASK

		; Palette
		ldx #0
		DO
			lda SnakePalette,x
			sta palette_1,x
		FOR X, NE, #$20, inx

		; Clear VRAM
		lda #$20
		sta PPUADDR
		lxa #0
		sta PPUADDR
		ldy #$08
		DO
			DO
				sta PPUDATA
			FOR X, NE, #0, inx
		FOR Y, NE, #0, dey

		; Un-clear RAM
		lda #$ff
		DO
			sta $7c0,x
			sta $3e0,x
		FOR X, NE, #$20, inx

		; Clear board
		lxa #0
		DO
			sta $400,x
			sta $500,x
			sta $600,x
			sta $6c0,x
		FOR X, NE, #0, inx

		ldx #4
		stx blacklisted_inputs
		stx frame_counter

		lda #$25
		sta PPUADDR
		and #$1f
		sta snake_head_pos+1
		lda #$af
		sta PPUADDR
		sta snake_head_pos
		lda #$15
		sta $5af
		and #$0f
		sta PPUDATA
		lda #$25
		sta PPUADDR
		and #$1f
		sta snake_tail_pos+1
		lda #$cf
		sta PPUADDR
		sta snake_tail_pos
		lda #$17
		sta $5cf
		and #$0f
		sta PPUDATA

		jsr CreateApple

		inc snake_direction
		inc game_paused

		jsr AfterPauseCode

		; Speed selection menu
		lda #1
		sta selected_option
		lda #$21
		sta PPUADDR
		lda #$c9
		sta PPUADDR
		lda #$3c
		sta PPUDATA
		lda #$21
		sta PPUADDR
		lda #$c9+13
		sta PPUADDR
		lda #$3e
		sta PPUDATA
				
		; Turn rendering and NMI back on
		lda #PPUCtrl_OnNormal
		sta ppuctrl_copy
		sta PPUCTRL
		lda #PPUMask_OnNormal
		sta PPUMASK

		rts


	Update:
		lda game_location
		IF A, EQ, #0
			sta scroll_nt

			ldx selected_option
			lda SnakeFrameCounterResets,x
			sta frame_counter_reset

			txa
			asl
			sta z:temp
			asl
			asl
			add z:temp
			tax
			ldy #0
			DO
				lda SnakeSpeedSelText,x
				sta vram_buffer_data,y
				lda #$21
				sta vram_buffer_adr_hi,y
				lda #$cb
				sty z:temp
				add z:temp
				sta vram_buffer_adr_lo,y
				inx
			FOR Y, NE, #10, iny
			sty z:vram_buffer_index

			lax z:controller_1_new
			and #DPad_Left
			IF NE
				dec z:selected_option
				IF MI
					lda #0
					sta z:selected_option
				END_IF
			END_IF
			txa
			and #DPad_Right
			IF NE
				inc z:selected_option
				lda z:selected_option
				IF A, EQ, #6
					dec z:selected_option
				END_IF
			END_IF
			txa
			and #Button_Start
			IF NE
				inc game_location
			END_IF

			rts
		END_IF

		lda #3
		sta scroll_nt

		ldy #0

		lda z:blacklisted_inputs
		eor #$ff
		and z:controller_1_current
		sta z:controller_1_current

		and #$ef
		IF NE
			sty game_paused
		END_IF

		; Update pause flag
		lda controller_1_new
		and #Button_Start
		IF NE
			lda game_paused
			eor #$01
			sta game_paused
		END_IF

		; Update snake direction
		lax controller_1_current

		and #DPad_Left
		beq :+
		lda #DPad_Right
		sta blacklisted_inputs
		sty snake_direction
		:

		txa
		and #DPad_Up
		beq :+
		lda #DPad_Down
		sta blacklisted_inputs
		lda #1
		sta snake_direction
		:

		txa
		and #DPad_Right
		beq :+
		lda #DPad_Left
		sta blacklisted_inputs
		lda #2
		sta snake_direction
		:

		txa
		and #DPad_Down
		beq :+
		lda #DPad_Up
		sta blacklisted_inputs
		lda #3
		sta snake_direction
		:

		; Frame counter / pause flag
		lda game_paused
		bne :+
		dec frame_counter
		bne :+
		lda frame_counter_reset
		sta frame_counter
		bne :++
		:
		rts
		:

		AfterPauseCode:

		; Move snake
		lda snake_head_pos
		sta last_snake_head_pos
		lda snake_head_pos+1
		sta last_snake_head_pos+1
		lda inc_tail_length
		beq :+
		lda snake_tail_pos
		sta last_snake_tail_pos
		lda snake_tail_pos+1
		sta last_snake_tail_pos+1
		:
		; Move head
		ldx snake_direction
		cpx #2
		bcc :+
		lda SnakePosHeadMoveLoBytes,x
		clc
		adc snake_head_pos
		sta snake_head_pos
		bcc :++
		inc snake_head_pos+1
		bne :++
		:
		lda snake_head_pos
		sec
		sbc SnakePosHeadMoveLoBytes,x
		sta snake_head_pos
		bcs :+
		dec snake_head_pos+1
		:
		; Move tail
		lda inc_tail_length
		beq :++
		lda (snake_tail_pos),y
		lsr
		lsr
		lsr
		lsr
		tax
		cpx #2
		bcc :+
		lda SnakePosTailMoveLoBytes,x
		clc
		adc snake_tail_pos
		sta snake_tail_pos
		bcc :++
		inc snake_tail_pos+1
		bne :++
		:
		lda snake_tail_pos
		sec
		sbc SnakePosTailMoveLoBytes,x
		sta snake_tail_pos
		bcs :+
		dec snake_tail_pos+1
		:

		; Prevent screen wrap
		; Left
		lda last_snake_head_pos
		and #$1f
		bne :+
		lda snake_head_pos
		and #$1f
		cmp #$1f
		bne :+
		jmp GameOver
		:
		; Right
		lda last_snake_head_pos
		and #$1f
		cmp #$1f
		bne :+
		lda snake_head_pos
		and #$1f
		bne :+
		jmp GameOver
		:

		lda #1
		sta inc_tail_length

		; Draw snake positions
		lda (snake_head_pos),y
		cmp #$01
		bne :+
		jsr CreateApple
		dec inc_tail_length
		:
		cmp #$02
		bcc :+
		jsr GameOver
		:
		; Draw snake head
		; Head
		lda snake_direction
		asl
		asl
		asl
		asl
		ora snake_direction
		clc
		adc #$4
		sta (snake_head_pos),y
		; Tile behind head
		lda (last_snake_head_pos),y
		and #$f0
		asl
		asl
		asl
		ora snake_direction
		rol
		rol
		tax
		lda NextSnakeTileData,x
		sta (last_snake_head_pos),y

		lda inc_tail_length
		beq :+
		; Tile behind tail
		lda #0
		sta (last_snake_tail_pos),y
		; Tail
		lda (snake_tail_pos),y
		and #$f0
		sta temp
		lsr
		lsr
		lsr
		lsr
		tax
		lda snake_directionInvert,x
		clc
		adc #$04
		ora temp
		sta (snake_tail_pos),y
		:

		; Draw tiles
		ldx vram_buffer_index
		lda last_snake_head_pos+1
		ora #$20
		sta vram_buffer_adr_hi,x
		lda last_snake_head_pos
		sta vram_buffer_adr_lo,x
		lda (last_snake_head_pos),y
		and #$0f
		sta vram_buffer_data,x
		inx

		lda snake_head_pos+1
		ora #$20
		sta vram_buffer_adr_hi,x
		lda snake_head_pos
		sta vram_buffer_adr_lo,x
		lda (snake_head_pos),y
		and #$0f
		sta vram_buffer_data,x
		inx

		lda last_snake_tail_pos+1
		ora #$20
		sta vram_buffer_adr_hi,x
		lda last_snake_tail_pos
		sta vram_buffer_adr_lo,x
		lda (last_snake_tail_pos),y
		and #$0f
		sta vram_buffer_data,x
		inx

		lda snake_tail_pos+1
		ora #$20
		sta vram_buffer_adr_hi,x
		lda snake_tail_pos
		sta vram_buffer_adr_lo,x
		lda (snake_tail_pos),y
		and #$0f
		sta vram_buffer_data,x
		inx
		stx vram_buffer_index

		rts


	jsr UpdateRNG
	.proc CreateApple
		lda rng_data
		sta apple_pos
		lda rng_data+1
		and #$03
		ora #$04
		sta apple_pos+1
		ldy #0
		lda (apple_pos),y
		bne CreateApple-3
		lda apple_pos
		IF A, EQ, #$07
			lda apple_pos+1
			cmp #$c0
			bcs CreateApple-3
		END_IF
		ldx vram_buffer_index
		lda apple_pos+1
		ora #$20
		sta vram_buffer_adr_hi,x
		lda apple_pos
		sta vram_buffer_adr_lo,x
		lda #$01
		sta vram_buffer_data,x
		sta (apple_pos),y
		inx
		stx vram_buffer_index
		rts
	.endproc


	.proc GameOver
		lda #$16
		sta palette_1+3
		DO
			lda controller_1_new
			and #Button_Start
		WHILE EQ
		jmp ($fffc)
		rts
	.endproc


	SnakeFrameCounterResets:
		.byte 14, 12, 10, 8, 6, 1

	SnakeSpeedSelText:
		.byte "   Slow   "
		.byte "  Normal  "
		.byte "   Fast   "
		.byte "Extra Fast"
		.byte "Super Fast"
		.byte " TAS Only "

	SnakePalette:
		.byte $0f, $16, $1a, $30
		.byte $0f, $16, $1a, $30
		.byte $0f, $16, $1a, $30
		.byte $0f, $16, $1a, $30

		.byte $0f, $16, $1a, $30
		.byte $0f, $16, $1a, $30
		.byte $0f, $16, $1a, $30
		.byte $0f, $16, $1a, $30

	SnakePosHeadMoveLoBytes:
	SnakePosTailMoveLoBytes:
		.byte $01, $20, $01, $20

	SnakeTailTiles:
		.byte $13, $02, $31, $20
	snake_directionInvert:
		.byte $02, $03, $00, $01

	NextSnakeTileData:
		; New Direction: Left
		; Previous Directions:
			; Left
			.byte $02
			; Up
			.byte $09
			; Right
			.byte $02
			; Down
			.byte $08
		; New Direction: Up
		; Previous Directions:
			; Left
			.byte $1a
			; Up
			.byte $13
			; Right
			.byte $18
			; Down
			.byte $13
		; New Direction: Right
		; Previous Direction:
			; Left
			.byte $22
			; Up
			.byte $2b
			; Right
			.byte $22
			; Down
			.byte $2a
		; New Direction: Down
		; Previous Directions:
			; Left
			.byte $3b
			; Up
			.byte $33
			; Right
			.byte $39
			; Down
			.byte $33

.endproc
