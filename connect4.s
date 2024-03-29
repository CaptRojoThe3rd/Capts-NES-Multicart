
.proc Connect4

	; Global vars are $00-$2f

	game_location				= $30
	game_type					= $31
	current_turn				= $32

	piece_column_selection		= $33
	piece_vert_animation		= $34
	piece_horz_animation		= $35

	piece_animation_x			= $36
	piece_animation_target_y	= $37
	piece_animation_target_slot	= $38

	switching_turn				= $39
	winning_player				= $3a

	winning_temp_a				= $3b
	winning_temp_x				= $3c
	winning_temp_y				= $3d

	winning_temp_tick			= $3e
	winning_temp_frame			= $3f
	winning_temp_direction		= $40

	board_main					= $300 ; 42 bytes, $300-$329
	board_computer_layer_0		= $32a ; 42 bytes, $32a-$353
	board_player_layer_0		= $354 ; 42 bytes, $354-$37d
	board_computer_layer_1		= $37e ; 42 bytes, $37e-$3a7
	board_player_layer_1		= $3a8 ; 42 bytes, $3a8-$3d1
	board_temp					= $3d2 ; 42 bytes, $3d2-$3fb

	

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
		lda #$08
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
				lda #248
				sta scroll_x
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
			lda piece_vert_animation
			IF EQ
				lda switching_turn
				IF NE
					dec switching_turn
					lda current_turn
					eor #$01
					sta current_turn
				END_IF
				
				lda winning_player
				IF EQ
					jsr RenderPieceAboveBoard
				ELSE
					inc winning_temp_frame
					lda winning_temp_frame
					cmp #5
					IF EQ
						lda #0
						sta winning_temp_frame

						lda winning_temp_direction
						IF EQ
							inc winning_temp_tick
							lda winning_temp_tick
							IF A, EQ, #5
								lda #1
								eor winning_temp_direction
								sta winning_temp_direction
							END_IF
						ELSE
							dec winning_temp_tick
							IF EQ
								lda #1
								eor winning_temp_direction
								sta winning_temp_direction
							END_IF
						END_IF
					END_IF
					
					; Draw winning highlight sprites
					; Top Left
					; Piece 1
					; Y
					lda winning_temp_y
					sta oam_buffer_buffer
					; ID
					lda winning_temp_tick
					add #3
					sta oam_buffer_buffer+1
					; Attributes
					lda #$02
					sta oam_buffer_buffer+2
					; X
					lda winning_temp_x
					sta oam_buffer_buffer+3
					jsr CopySpriteToBuffer
					; Piece 2
					jsr AddToBaseWinPos
					jsr CopySpriteToBuffer
					; Piece 3
					jsr AddToBaseWinPos
					jsr CopySpriteToBuffer
					; Piece 4
					jsr AddToBaseWinPos
					jsr CopySpriteToBuffer
				END_IF
			ELSE
				inc piece_vert_animation
				lda piece_vert_animation
				cmp piece_animation_target_y
				IF EQ
					lda #0
					sta piece_vert_animation
					jmp :+
				END_IF
				lda #0
				sta controller_1_new
				sta controller_2_new
				; Draw piece falling
				; Move sprites to lower priorty positions
				lda #$80
				sta oam_buffer_index
				jsr RenderPieceAboveBoard
				lda piece_vert_animation
				sta oam_buffer+128
				sta oam_buffer+12+128
				add #8
				sta oam_buffer+4+128
				sta oam_buffer+8+128
				; Cover falling piece with board
				lda #0
				sta oam_buffer_index
				; Top left
				; Y
				lda #63
				sta oam_buffer_buffer
				; ID
				lda #$04
				sta oam_buffer_buffer+1
				; Attributes
				lda #$03
				sta oam_buffer_buffer+2
				; X
				lda piece_animation_x
				sta oam_buffer_buffer+3
				ldy #0
				DO
					jsr CopySpriteToBuffer
					lda oam_buffer_buffer
					add #16
					sta oam_buffer_buffer
				FOR Y, NE, #6, iny
				; Bottom left
				; Y
				lda #71
				sta oam_buffer_buffer
				; Attributes
				lda #$83
				sta oam_buffer_buffer+2
				ldy #0
				DO
					jsr CopySpriteToBuffer
					lda oam_buffer_buffer
					add #16
					sta oam_buffer_buffer
				FOR Y, NE, #6, iny
				; Bottom Right
				; Y
				lda #71
				sta oam_buffer_buffer
				; Attributes
				lda #$c3
				sta oam_buffer_buffer+2
				; X
				lda piece_animation_x
				add #8
				sta oam_buffer_buffer+3
				ldy #0
				DO
					jsr CopySpriteToBuffer
					lda oam_buffer_buffer
					add #16
					sta oam_buffer_buffer
				FOR Y, NE, #6, iny
				; Top Right
				; Y
				lda #63
				sta oam_buffer_buffer
				; Attributes
				lda #$43
				sta oam_buffer_buffer+2
				ldy #0
				DO
					jsr CopySpriteToBuffer
					lda oam_buffer_buffer
					add #16
					sta oam_buffer_buffer
				FOR Y, NE, #6, iny

				; Return OAM buffer index to normal
				lda #$90
				sta oam_buffer_index
			END_IF
			:

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
				jsr HandleTurn
			ELSE
				; Player 2 / Computer
				lda game_type
				IF EQ
					; Player 2
					jsr HandleTurn
				ELSE
					; Computer
					
				END_IF
			END_IF
		END_IF

		; Draw to screen
		ldx vram_buffer_index

		; Attribute Addresses
		ldx vram_buffer_index
		ldy #0
		DO
			lda #$23
			sta vram_buffer_adr_hi,x
			lda Connect4AttrAddrsLo,x
			sta vram_buffer_adr_lo,x
			inx
		FOR Y, NE, #12, iny

		lda piece_vert_animation
		IF EQ
			stx vram_buffer_index
		END_IF

		; Data
		; (0, 0) - (1, 1)
		lda board_main+7+1
		asl
		asl
		ora board_main+7
		asl
		asl
		ora board_main+1
		asl
		asl
		ora board_main
		sta vram_buffer_data
		; (2, 0) - (3, 1)
		lda board_main+7+2+1
		asl
		asl
		ora board_main+7+2
		asl
		asl
		ora board_main+2+1
		asl
		asl
		ora board_main+2
		sta vram_buffer_data+1
		; (4, 0) - (5, 1)
		lda board_main+7+4+1
		asl
		asl
		ora board_main+7+4
		asl
		asl
		ora board_main+4+1
		asl
		asl
		ora board_main+4
		sta vram_buffer_data+2
		; (6, 0) - (6, 1)
		lda board_main+7+6
		asl
		asl
		asl
		asl
		ora board_main+6
		sta vram_buffer_data+3
		; (0, 2) - (1, 3)
		lda board_main+14+7+1
		asl
		asl
		ora board_main+14+7
		asl
		asl
		ora board_main+14+1
		asl
		asl
		ora board_main+14
		sta vram_buffer_data+4
		; (2, 2) - (3, 3)
		lda board_main+14+7+2+1
		asl
		asl
		ora board_main+14+7+2
		asl
		asl
		ora board_main+14+2+1
		asl
		asl
		ora board_main+14+2
		sta vram_buffer_data+5
		; (4, 2) - (5, 3)
		lda board_main+14+7+4+1
		asl
		asl
		ora board_main+14+7+4
		asl
		asl
		ora board_main+14+4+1
		asl
		asl
		ora board_main+14+4
		sta vram_buffer_data+6
		; (6, 2) - (6, 3)
		lda board_main+14+7+6
		asl
		asl
		asl
		asl
		ora board_main+14+6
		sta vram_buffer_data+7
		; (0, 4) - (1, 5)
		lda board_main+28+7+1
		asl
		asl
		ora board_main+28+7
		asl
		asl
		ora board_main+28+1
		asl
		asl
		ora board_main+28
		sta vram_buffer_data+8
		; (2, 4) - (3, 5)
		lda board_main+28+7+2+1
		asl
		asl
		ora board_main+28+7+2
		asl
		asl
		ora board_main+28+2+1
		asl
		asl
		ora board_main+28+2
		sta vram_buffer_data+9
		; (4, 4) - (5, 5)
		lda board_main+28+7+4+1
		asl
		asl
		ora board_main+28+7+4
		asl
		asl
		ora board_main+28+4+1
		asl
		asl
		ora board_main+28+4
		sta vram_buffer_data+10
		; (6, 4) - (6, 5)
		lda board_main+28+7+6
		asl
		asl
		asl
		asl
		ora board_main+28+6
		sta vram_buffer_data+11


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
		lda #$00
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
		lda #$80
		ora current_turn
		sta oam_buffer_buffer+2
		jsr CopySpriteToBuffer

		; Bottom Right
		; X
		lda oam_buffer_buffer+3
		add #8
		sta oam_buffer_buffer+3
		; Attributes
		lda #$c0
		ora current_turn
		sta oam_buffer_buffer+2
		jsr CopySpriteToBuffer

		; Top Right
		; Y
		lda #46
		sta oam_buffer_buffer
		; Attributes
		lda #$40
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
			; Get what is in the slot
			lda (temp+2),y

			; If piece is there, return
			bne :+

			; Increment row counter (add 7 to slot counter)
			tya
			add #7
			tay
		FOR X, NE, #6, inx


		:
		; If all 6 rows are checked, exit loop and return bottom slot index

		tya
		sub #7
		tay


		; If X is zero, the column is full. Return $ff.
		cpx #0
		IF EQ
			dex
		END_IF

		rts
	.endproc


	.proc HandleTurn
		lda current_turn
		asl
		ora current_turn
		tax

		lda z:controller_1_new,x
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
				; Place piece
				lda #<board_main
				sta temp+2
				lda #>board_main
				sta temp+3
				jsr GetRowToDropPiece
				lda #1
				clc
				adc current_turn
				sta board_main,y

				; Begin animation
				sty piece_animation_target_slot
				lda Connect4TargetYs,y
				sta piece_animation_target_y
				lda #46
				sta piece_vert_animation
				lda piece_column_selection
				asl
				asl
				asl
				asl
				adc #72
				sta piece_animation_x

				lda #<board_main
				sta temp+4
				lda #>board_main
				sta temp+5
				ldx current_turn
				inx
				stx temp+6
				jsr CheckForWin
				IF EQ
					ldx current_turn
					inx
					stx winning_player

					lda winning_temp_x
					asl
					asl
					asl
					asl
					adc #72
					sta winning_temp_x
					lda winning_temp_y
					asl
					asl
					asl
					asl
					adc #64
					sta winning_temp_y
				END_IF

				; Switch turn
				inc switching_turn
			END_IF
		END_IF

		rts
	.endproc


	.proc CheckForWin
		; Addr is stored in temp+4 and 5
		; Player is stored in temp+6
		; Win status is in temp+7
		; Win detection temp is in temp+8


		ldy #41
		DO
			lda (temp+4),y
			sta board_temp,y
		FOR Y, PL, #$ff, dey

		; -
		ldx #0
		stx winning_temp_a
		stx winning_temp_x
		stx winning_temp_y
		ldy #0
		DO
			; (0, y) - (3, y)
			lda #0
			sta temp+8
			lda board_temp,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			cmp #4
			IF EQ
				rts
			END_IF

			inc winning_temp_x ; 1

			; (1, y) - (4, y)
			lda #0
			sta temp+8
			lda board_temp+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+4,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			cmp #4
			IF EQ
				rts
			END_IF

			inc winning_temp_x ; 2

			; (2, y) - (5, y)
			lda #0
			sta temp+8
			lda board_temp+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+4,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+5,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			cmp #4
			IF EQ
				rts
			END_IF

			inc winning_temp_x ; 3

			; (3, y) - (6, y)
			lda #0
			sta temp+8
			lda board_temp+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+4,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+5,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+6,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			cmp #4
			IF EQ
				rts
			END_IF

			lda #0
			sta winning_temp_x
			inc winning_temp_y

			inx2
			inx2
			inx2
			inx
		FOR Y, NE, #6, iny

		; |
		lda #1
		sta winning_temp_a
		ldx #0
		stx winning_temp_x
		stx winning_temp_y
		ldy #0
		DO
			; (x, 0) - (x, 3)
			lda #0
			sta temp+8
			lda board_temp,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+7,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			inc winning_temp_y ; 1

			; (x, 1) - (x, 4)
			lda #0
			sta temp+8
			lda board_temp+7,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+28,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			inc winning_temp_y ; 2

			; (x, 2) - (x, 5)
			lda #0
			sta temp+8
			lda board_temp+14,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+28,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+35,y
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			lda #0
			sta winning_temp_y
			inc winning_temp_x
			
			iny
		FOR X, NE, #7, inx

		; \
		lda #2
		sta winning_temp_a
		ldx #0
		stx winning_temp_x
		stx winning_temp_y
		ldy #0
		DO
			; (0+x, 0); (1+x, 1); (2+x, 2); (3+x, 3)
			lda #0
			sta temp+8
			lda board_temp+0,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+7+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			inc winning_temp_y ; 1

			; (0+x, 1); (1+x, 2); (2+x, 3); (3+x, 4)
			lda #0
			sta temp+8
			lda board_temp+7,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+28+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			inc winning_temp_y ; 2

			; (0+x, 2); (1+x, 3); (2+x, 4); (3+x, 5)
			lda #0
			sta temp+8
			lda board_temp+14,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+28+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+35+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			lda #0
			sta winning_temp_y
			inc winning_temp_x

			inx
		FOR Y, NE, #4, iny

		; /
		lda #3
		sta winning_temp_a
		ldx #0
		stx winning_temp_x
		stx winning_temp_y
		ldy #0
		DO
			; (3+x, 0); (2+x, 1); (1+x, 2); (0+x, 3)
			lda #0
			sta temp+8
			lda board_temp+21,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+7+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			inc winning_temp_y ; 1

			; (3+x, 1); (2+x, 2); (1+x, 3); (0+x, 4)
			lda #0
			sta temp+8
			lda board_temp+28,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+7+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			inc winning_temp_y ; 2

			; (3+x, 2); (2+x, 3); (1+x, 4); (0+x, 5)
			lda #0
			sta temp+8
			lda board_temp+35,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+28+1,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+21+2,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda board_temp+14+3,x
			cmp temp+6
			IF EQ
				inc temp+8
			END_IF
			lda temp+8
			IF A, EQ, #4
				rts
			END_IF

			lda #0
			sta winning_temp_y
			inc winning_temp_x

			inx
		FOR Y, NE, #4, iny

		lda #$ff
		rts
	.endproc


	.proc AddToBaseWinPos
		SWITCH winning_temp_a
			CASE #0
				lda oam_buffer_buffer+3
				add #16
				sta oam_buffer_buffer+3
			CASE #1
				lda oam_buffer_buffer
				add #16
				sta oam_buffer_buffer
			CASE #2
				lda oam_buffer_buffer+3
				add #16
				sta oam_buffer_buffer+3
				lda oam_buffer_buffer
				add #16
				sta oam_buffer_buffer
			CASE #3
				lda oam_buffer_buffer+3
				add #16
				sta oam_buffer_buffer+3
				lda oam_buffer_buffer
				sub #16
				sta oam_buffer_buffer
		END_SWITCH

		rts
	.endproc

	.proc SubToBaseWinPos
		SWITCH winning_temp_a
			CASE #0
				lda oam_buffer_buffer+3
				sub #64
				sta oam_buffer_buffer+3
			CASE #1
				lda oam_buffer_buffer
				sub #64
				sta oam_buffer_buffer
			CASE #2
				lda oam_buffer_buffer+3
				sub #64
				sta oam_buffer_buffer+3
				lda oam_buffer_buffer
				sub #64
				sta oam_buffer_buffer
			CASE #3
				lda oam_buffer_buffer+3
				sub #64
				sta oam_buffer_buffer+3
				lda oam_buffer_buffer
				add #64
				sta oam_buffer_buffer
		END_SWITCH

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

	Connect4TargetYs:
		.byte 63, 63, 63, 63, 63, 63, 63
		.byte 79, 79, 79, 79, 79, 79, 79
		.byte 95, 95, 95, 95, 95, 95, 95
		.byte 111, 111, 111, 111, 111, 111, 111
		.byte 127, 127, 127, 127, 127, 127, 127
		.byte 143, 143, 143, 143, 143, 143, 143

	Connect4AttrAddrsLo:
		.byte $d2, $d3, $d4, $d5
		.byte $da, $db, $dc, $dd
		.byte $e2, $e3, $e4, $e5

.endproc
