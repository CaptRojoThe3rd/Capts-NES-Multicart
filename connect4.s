
.proc Connect4

	; Global vars are $00-$2f

	game_location			= $30
	game_type				= $31
	current_turn			= $32

	piece_column_selection	= $33
	piece_animating			= $34
	piece_animation_frame	= $35
	piece_horz_animation	= $36

	board_main				= $300 ; 42 bytes, $300-$329
	board_computer_layer_0	= $32a ; 42 bytes, $32a-$353
	board_player_layer_0	= $354 ; 42 bytes, $354-$37d
	board_computer_layer_1	= $37e ; 42 bytes, $37e-$3a7
	board_player_layer_1	= $3a8 ; 42 bytes, $3a8-$3d1

	

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

		sta z:game_location
		sta z:game_type
		sta z:current_turn
		sta z:controller_1_new
		sta z:controller_2_new

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

		lda #$25
		sta PPUADDR
		lda #$87
		sta PPUADDR
		ldx #$ff
		DO
			inx
			lda Connect4Text_PlayerVSPlayer,x
			sta PPUDATA
		WHILE NE

		lda #$25
		sta PPUADDR
		lda #$c6
		sta PPUADDR
		ldx #$ff
		DO
			inx
			lda Connect4Text_PlayerVSComputer,x
			sta PPUDATA
		WHILE NE

		lda ppuctrl_copy
		ora #$01
		sta ppuctrl_copy

		lda #3
		sta piece_column_selection

		ldx #0
		DO
			lda Connect4Palette,x
			sta palette_1,x
		FOR X, NE, #32, inx

		lda #$0f
		sta palette_1
		sta palette_1+16

		lda #PPUCtrl_OnNormal
		sta PPUCTRL
		lda #PPUMask_OnNormal
		sta PPUMASK

		rts
	.endproc

	.proc Update
		lda game_location
		IF EQ
			; Selection
			lda controller_1_new
			tax
			and #(DPad_Down|DPad_Up|Button_Select)
			IF NE
				lsr z:game_type
				IF CC
					sec
					rol z:game_type
				END_IF
			END_IF
			txa
			and #Button_Start
			IF NE
				inc z:game_location
				dec ppuctrl_copy
				lda #$1c
				sta palette_1
				sta palette_1+16
				rts
			END_IF


			; Sprites
			lda #32
			sta oam_buffer_buffer+3
			lda #3
			sta oam_buffer_buffer+2
			lda #0
			sta oam_buffer_buffer+1
			ldx game_type
			lda Connect4OptionYPos,x
			sta oam_buffer_buffer
			jsr CopySpriteToBuffer
			lda #208
			sta oam_buffer_buffer+3
			lda #$43
			sta oam_buffer_buffer+2
			jsr CopySpriteToBuffer
		ELSE
			; Draw piece above board if animation is not being played
			lda piece_animating
			IF EQ
				jsr RenderPieceAboveBoard
			END_IF

			; Animations
			lda piece_horz_animation
			IF NE
				IF MI
					inc piece_horz_animation
				ELSE
					dec piece_horz_animation
				END_IF
			END_IF


			; Handle turns
			lda z:current_turn
			IF EQ
				; Player 1
				lda z:controller_1_new
				tax
				
				; Move left
				and #DPad_Left
				IF NE
					dec z:piece_column_selection
					IF MI
						inc z:piece_column_selection
					ELSE
						lda #16
						add z:piece_horz_animation
						sta z:piece_horz_animation
					END_IF
				END_IF

				; Move right
				txa
				and #DPad_Right
				IF NE
					inc z:piece_column_selection
					lda z:piece_column_selection
					IF A, EQ, #7
						lda #6
						sta z:piece_column_selection
					ELSE
						lda #240
						add z:piece_horz_animation
						sta z:piece_horz_animation
					END_IF
				END_IF

				; Drop piece
				txa
				and #DPad_Down
				IF NE
					ldx piece_column_selection
					lda board_main,x
					IF EQ
						lda #<board_main
						sta temp+2
						lda #>board_main
						sta temp+3
						jsr GetRowToDropPiece
						lda #1
						sta board_main,y
					END_IF
				END_IF

			ELSE
				; Player 2 / Computer
				lda game_type
				IF EQ
					; Player 2
					
				ELSE
					; Computer
					
				END_IF
			END_IF
		END_IF

		rts
	.endproc


	.proc RenderPieceAboveBoard
		; Top Left
		; X
		lda piece_column_selection
		asl
		asl
		asl
		asl
		adc #72
		adc piece_horz_animation
		sta oam_buffer_buffer+3
		; Y
		lda #46
		sta oam_buffer_buffer
		; Attributes
		lda #$20
		ora current_turn
		sta oam_buffer_buffer+2
		; ID
		lda #$01
		sta oam_buffer_buffer+1
		jsr CopySpriteToBuffer
		
		; Bottom Left
		; ID
		inc oam_buffer_buffer+1
		; Y
		lda #54
		sta oam_buffer_buffer
		; Attributes
		lda #$a0
		ora current_turn
		sta oam_buffer_buffer+2
		jsr CopySpriteToBuffer

		; Bottom Right
		; X
		lda oam_buffer_buffer+3
		add #8
		sta oam_buffer_buffer+3
		; Attributes
		lda #$e0
		ora current_turn
		sta oam_buffer_buffer+2
		jsr CopySpriteToBuffer

		; Top Right
		; Y
		lda #46
		sta oam_buffer_buffer
		; Attributes
		lda #$60
		ora current_turn
		sta oam_buffer_buffer+2
		jsr CopySpriteToBuffer

		rts
	.endproc


	.proc GetRowToDropPiece
		txa
		tay

		ldx #0

		DO
			lda (temp+2),y
			bne :+
			tya
			add #7
			tay
		FOR X, NE, #5, inx

		:

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
		.byte $1c, $1c, $13, $30

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

	Connect4Text_PlayerVSPlayer:
		.byte "Player VS. Player", $00
	
	Connect4Text_PlayerVSComputer:
		.byte "Player VS. Computer", $00

	Connect4OptionYPos:
		.byte 95, 111

.endproc
