

; CA65 Macros

; add, sub, bge, blt, bgt, ble, bnz, bze
.macpack generic

; jeq, jne, jcc, jcs, jvc, jvs, jmi, jpl
.macpack longbranch



; Instruction Macros


; STP
.macro stp
	.byte $22
.endmacro


; LXA
.macro lxa arg1
	.if (.match (.left (1, {arg1}), #))
		.if (.xmatch (arg1, #0))
			.byte $ab, 0
		.else
			lda arg1
			tax
		.endif
	.else
		.fatal "Illegal addressing mode for LXA"
	.endif
.endmacro


; Longer NOPs
.macro nop3
	nop $ea
.endmacro

.macro nop4
	nop $ea,x
.endmacro

