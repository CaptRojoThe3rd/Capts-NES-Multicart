
.proc TitleScreen

	; Global vars are $00-$2f

	selected_option				= $30
	selected_option_frame		= $31
	selected_option_counter		= $32
	

	.proc Init
		; Draw title screen
		; Palette
		ldx #0
		DO
			lda CartTitlePalette,x
			sta palette_1,x
		FOR X, NE, #$20, inx

		; Title
		ldax #$2100
		stax PPUADDR
		ldx #$ff
		DO
			inx
			lda CartTitle,x
			sta PPUDATA
		WHILE NE

		; Game List
		ldax #$21e0
		stax PPUADDR
		ldx #$ff
		DO
			inx
			lda CartGameList,x
			sta PPUDATA
		WHILE NE

		; Var init
		inc oam_buffer_used

		; Turn on NMI and rendering
		lda #PPUCtrl_OnNormal
		sta ppuctrl_copy
		sta PPUCTRL
		lda #PPUMask_OnNormal
		sta PPUMASK

		rts
	.endproc

	.proc Update
		; Selected option sprite
		; ID
		lda #0
		sta oam_buffer_buffer+1
		; Attributes
		lda selected_option_frame
		sta oam_buffer_buffer+2
		; Y
		ldx selected_option
		lda SelectedOptionSpriteYs,x
		sta oam_buffer_buffer
		; X
		lda SelectedOptionSpriteXs,x
		sta oam_buffer_buffer+3
		jsr CopySpriteToBuffer

		; Animate color of selected option sprite
		dec selected_option_counter
		IF MI
			lda #29
			sta z:selected_option_counter
			lda z:selected_option_frame
			eor #$01
			sta z:selected_option_frame
		END_IF

		clc
		lda controller_1_new
		tax
		and #DPad_Down
		IF NE
			lda z:selected_option
			adc #1
			and #7
			sta z:selected_option
		END_IF
		txa
		and #DPad_Up
		IF NE
			lda z:selected_option
			sbc #0
			and #7
			sta z:selected_option
		END_IF
		clc
		txa
		and #DPad_Right
		IF NE
			lda z:selected_option
			adc #4
			and #7
			sta z:selected_option
		END_IF
		txa
		and #DPad_Left
		IF NE
			lda z:selected_option
			sbc #3
			and #7
			sta z:selected_option
		END_IF
		txa
		and #Button_Select
		IF NE
			inc z:selected_option
		END_IF
		txa
		and #Button_Start
		IF NE
			ldx z:selected_option
			inx
			stx current_program
			jsr InitProgram
		END_IF

		rts
	.endproc

	SelectedOptionSpriteXs:
		.byte 16, 16, 16, 16, 128, 128, 128, 128
	SelectedOptionSpriteYs:
		.byte 119, 127, 135, 143, 119, 127, 135, 143

.endproc
