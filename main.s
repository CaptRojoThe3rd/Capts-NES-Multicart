
.segment "PRG_0"

.include "labels/labels.s"
.include "labels/nes.s"

.include "macros/macros.s"
.include "macros/16bit.s"
.include "macros/stack.s"
.include "macros/structure.s"

.include "nmi.s"
.include "irq.s"

.include "title_screen.s"
.include "snake.s"
.include "connect4.s"

.include "reset.s"

.proc Main

	jsr InitProgram

	; Main loop
	DO
		jsr WaitForNMI

		; Clear OAM buffer
		lda oam_buffer_used
		IF NE
			lda #$ff
			ldx #0
			stx z:oam_buffer_used
			DO
				sta oam_buffer,x
			FOR X, NE, oam_buffer_index, inx, 4
			lda #0
			sta oam_buffer_index
		END_IF

		; Update RNG
		jsr UpdateRNG

		; Update program
		lda current_program
		asl
		tax
		lda CartProgramUpdateAddrs,x
		sta temp
		lda CartProgramUpdateAddrs+1,x
		sta temp+1
		lda #>:+
		pha
		lda #<:+-1
		pha
		jmp (temp)
		:

		bit PPUSTATUS


	WHILE TRUE

.endproc


.proc UpdateRNG ; Needs to be a seperate routine for snake
	ldy rng_data+2
	lda rng_data+1
	sta rng_data+2
	lda rng_data+3
	lsr
	sta rng_data+1
	lsr
	lsr
	lsr
	lsr
	eor rng_data+1
	lsr
	eor rng_data+1
	eor rng_data+0
	sta rng_data+1
	lda rng_data+3
	asl
	eor rng_data+3
	asl
	asl
	asl
	asl
	eor rng_data+3
	asl
	asl
	eor rng_data+3
	sty rng_data+3
	sta rng_data+0
	rts
.endproc


.proc InitProgram
	lda current_program
	asl
	tax
	lda CartProgramInitAddrs,x
	sta temp
	lda CartProgramInitAddrs+1,x
	sta temp+1
	jmp (temp)
.endproc


.proc CopySpriteToBuffer
	ldx oam_buffer_index
	; Y
	lda oam_buffer_buffer
	sta oam_buffer,x
	inx
	; ID
	lda oam_buffer_buffer+1
	sta oam_buffer,x
	inx
	; Attributes
	lda oam_buffer_buffer+2
	sta oam_buffer,x
	inx
	; X
	lda oam_buffer_buffer+3
	sta oam_buffer,x
	inx
	stx oam_buffer_index
	inc oam_buffer_used
	rts
.endproc


CartTitle:
	.byte "     ", $0c, $0d, "   Capt's NES 8-in-1     "
	.byte "     ", $0e, $0f, "   Multicart", $00

CartGameList:
	.byte "   1. Snake      5.Flappy Bird  "
	.byte "   2. Connect 4  6.             "
	.byte "   3. Dinosaur   7.             "
	.byte "   4. Tetris     8.", $00

CartTitlePalette:
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30

	.byte $0f, $00, $13, $30
	.byte $0f, $00, $23, $30
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30

CartProgramInitAddrs:
	.word TitleScreen::Init
	.word Snake::Init
	.word Connect4::Init

CartProgramUpdateAddrs:
	.word TitleScreen::Update
	.word Snake::Update
	.word Connect4::Update


.segment "CHR"
	.incbin "chr/alpha.chr"

.segment "VECTORS"
	.word NMI
	.word Reset
	.word IRQ

.segment "HEADER"
	.byte $4e, $45, $53, $1a
	.byte $02, $01, $01, $08
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $01
