

.macro ldax arg1, arg2
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		lda arg1 & $ff
		ldx arg1 >> 8

	; Not Immediate
	.else

		; Indexed
		.if .paramcount = 2
			
			; Indirect Indexed
			.if (.match (.left (1, {arg1}), {(}))
				iny
				lax (arg1),y
				dey
				lda (arg1),y
				iny

			; Indexed
			.else
				lda arg1,y
				ldx arg1+1,y
			.endif

		; Absolute
		.else
			lda arg1
			ldx arg1+1
		.endif

	.endif

.endmacro


.macro lday arg1, arg2
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		lda arg1 & $ff
		ldy arg1 >> 8

	; Not Immediate
	.else

		; Indexed
		.if .paramcount = 2

			lda arg1,x
			ldy arg1+1,x

		; Absolute
		.else
			lda arg1
			ldy arg1+1
		.endif

	.endif

.endmacro


.macro ldxy arg1
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		ldx arg1 & $ff
		ldy arg1 >> 8

	; Absolute
	.else 

		ldx arg1
		ldy arg1+1

	.endif

.endmacro


.macro stax arg1, arg2
	
	; Indexed
	.if .paramcount = 2

		sta arg1,y
		stx arg1+1,y

	; Absolute
	.else

		.if (.xmatch (arg1, $2006)) .or (.xmatch (arg1, PPUADDR))
			stx arg1
			sta arg1
		.elseif (.xmatch (arg1, $2005)) .or (.xmatch (arg1, PPUSCROLL))
			sta arg1
			stx arg1
		.else
			sta arg1
			stx arg1+1
		.endif

	.endif

.endmacro


.macro stay arg1, arg2
	
	; Indexed
	.if .paramcount = 2

		sta arg1,x
		sty arg1+1,x

	; Absolute
	.else

		.if (.xmatch (arg1, $2006)) .or (.xmatch (arg1, PPUADDR))
			sty arg1
			sta arg1
		.elseif (.xmatch (arg1, $2005)) .or (.xmatch (arg1, PPUSCROLL))
			sta arg1
			sty arg1
		.else
			sta arg1
			sty arg1+1
		.endif

	.endif

.endmacro


.macro stxy arg1

	sta arg1
	sty arg1+1

.endmacro


.macro adcax arg1, arg2
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		adc arg1 & $ff
		pha
		txa
		adc arg1 >> 8
		tax
		pla

	; Not Immediate
	.else

		; Indexed
		.if .paramcount = 2
			
			; Indirect Indexed
			.if (.match (.left (1, {arg1}), {(}))
				adc (arg1),y
				pha
				txa
				iny
				adc (arg1),y
				tax
				pla

			; Indexed
			.else
				adc arg1,y
				pha
				txa
				adc arg1+1,y
				tax
				pla
			.endif

		; Absolute
		.else
			adc arg1
			pha
			txa
			adc arg1+1
			tax
			pla
		.endif

	.endif

.endmacro


.macro adcay arg1, arg2
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		adc arg1 & $ff
		pha
		tya
		adc arg1 >> 8
		tay
		pla

	; Not Immediate
	.else

		; Indexed
		.if .paramcount = 2

			adc arg1,x
			pha
			tya
			adc arg1+1,x
			tay
			pla

		; Absolute
		.else
			adc arg1
			pha
			tya
			adc arg1+1
			tay
			pla
		.endif

	.endif

.endmacro


.macro addax arg1, arg2
	clc
	adcax arg1, arg2
.endmacro


.macro adday arg1, arg2
	clc
	adcay arg1, arg2
.endmacro


.macro adc16 arg1, arg2
	.if (.match (.left (1, {arg1}), #))

		.if (.match (.left (1, {arg2}), #))
			.fatal "Both arguments for add16 are immediate values"
		.endif

		lda arg1 & $ff
		adc arg2
		sta arg2
		lda arg1 >> 8
		adc arg2+1
		sta arg2+1

	.else

		.if (.match (.left (1, {arg2}), #))
			
			lda arg2 & $ff
			adc arg1
			sta arg1
			lda arg2 >> 8
			adc arg1+1
			sta arg1+1

		.else

			lda arg2
			adc arg1
			sta arg1
			lda arg2+1
			adc arg1+1
			sta arg1+1

		.endif

	.endif

.endmacro


.macro add16 arg1, arg2
	clc
	adc16 arg1, arg2
.endmacro


.macro sbcax arg1, arg2
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		sbc arg1 & $ff
		pha
		txa
		sbc arg1 >> 8
		tax
		pla

	; Not Immediate
	.else

		; Indexed
		.if .paramcount = 2
			
			; Indirect Indexed
			.if (.match (.left (1, {arg1}), {(}))
				iny
				sbc (arg1),y
				pha
				txa
				dey
				sbc (arg1),y
				tax
				pla
				iny

			; Indexed
			.else
				sbc arg1,y
				pha
				txa
				iny
				sbc arg1,y
				tax
				pla
			.endif

		; Absolute
		.else
			sbc arg1
			pha
			txa
			sbc arg1+1
			tax
			pla
		.endif

	.endif

.endmacro


.macro sbcay arg1, arg2
	
	; Immediate
	.if (.match (.left (1, {arg1}), #))

		sbc arg1 & $ff
		pha
		tya
		sbc arg1 >> 8
		tay
		pla

	; Not Immediate
	.else

		; Indexed
		.if .paramcount = 2

			sbc arg1,x
			pha
			tya
			sbc arg1+1,x
			tay
			pla

		; Absolute
		.else
			sbc arg1
			pha
			tya
			sbc arg1+1
			tay
			pla
		.endif

	.endif

.endmacro


.macro subax arg1, arg2
	sec
	sbcax arg1, arg2
.endmacro


.macro subay arg1, arg2
	sec
	sbcay arg1, arg2
.endmacro


.macro sbc16 arg1, arg2

	.if (.match (.left (1, {arg1}), #))

		.if (.match (.left (1, {arg2}), #))
			.fatal "Both arguments for sub16 are immediate values"
		.endif

		lda arg2
		sbc arg1 & $ff
		sta arg2
		lda arg2+1
		sbc arg1 >> 8
		sta arg2+1

	.else

		.if (.match (.left (1, {arg2}), #))

			lda arg1
			sbc arg2 & $ff
			sta arg1
			lda arg1+1
			sbc arg2 >> 8
			sta arg1+1

		.else

			lda arg1
			sbc arg2
			sta arg1
			lda arg+1
			sbc arg+2
			sta arg+1

		.endif

	.endif

.endmacro


.macro sub16 arg1, arg2
	sec
	sbc16 arg1, arg2
.endmacro


.macro inc16 arg1, arg2
	
	.if (.paramcount = 2)

			inc arg1,x
			bne :+
			inc arg1+1,x
			:
		
		.endif

	.else

		inc arg1
		bne :+
		inc arg1+1
		:

	.endif

.endmacro


.macro dec16 arg1, arg2
	
	.if (.paramcount = 2)

			dec arg1,x
			bne :+
			dec arg1+1,x
			:
		
		.endif

	.else

		dec arg1
		bne :+
		dec arg1+1
		:

	.endif

.endmacro


.macro inx2
	inx
	inx
.endmacro


.macro iny2
	iny
	iny
.endmacro


.macro dex2
	dex
	dex
.endmacro


.macro dey2
	dey
	dey
.endmacro

