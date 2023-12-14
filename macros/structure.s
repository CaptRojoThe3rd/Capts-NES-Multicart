

.define EQ 0
.define NE 1
.define CC 2
.define CS 3
.define VC 4
.define VS 5
.define MI 6
.define PL 7

.define LT CC
.define GE CS
.define NG MI
.define PS PL

.define LE 8
.define GT 9

.define TRUE 10


__depth__ .set 0
__elseifcount__ .set 0
__casedefined__ .set 0


.macro IF arg1, arg2, arg3

	.if (.xmatch (arg1, A))
		cmp arg3
		IF arg2
		.exitmacro
	.elseif (.xmatch (arg1, X))
		cpx arg3
		IF arg2
		.exitmacro
	.elseif (.xmatch (arg1, Y))
		cpy arg3
		IF arg2
		.exitmacro
	.endif
	
	; EQ (Equal)
	.if (.xmatch (arg1, EQ))

		::__depth__ .set ::__depth__ + 1
		.scope
		bne .ident(.sprintf("__else__%d", ::__depth__))		
	
	; NE (Not Equal)
	.elseif (.xmatch (arg1, 1))

		::__depth__ .set ::__depth__ + 1
		.scope
		beq .ident(.sprintf("__else__%d", ::__depth__))	

	; CC (Carry Clear / Less Than)
	.elseif (.xmatch (arg1, CC))

		::__depth__ .set ::__depth__ + 1
		.scope
		bcs .ident(.sprintf("__else__%d", ::__depth__))	

	; CS (Carry Set / Greater Than Or Equal To)
	.elseif (.xmatch (arg1, CS))

		::__depth__ .set ::__depth__ + 1
		.scope
		bcc .ident(.sprintf("__else__%d", ::__depth__))

	; VC (Overflow Clear)
	.elseif (.xmatch (arg1, VC))

		::__depth__ .set ::__depth__ + 1
		.scope
		bvs .ident(.sprintf("__else__%d", ::__depth__))

	; VS (Overflow Set)
	.elseif (.xmatch (arg1, VS))

		::__depth__ .set ::__depth__ + 1
		.scope
		bvc .ident(.sprintf("__else__%d", ::__depth__))

	; MI (Negative Set / Negative)
	.elseif (.xmatch (arg1, MI))

		::__depth__ .set ::__depth__ + 1
		.scope
		bpl .ident(.sprintf("__else__%d", ::__depth__))

	; PL (Negative Clear / Positive)
	.elseif (.xmatch (arg1, PL))

		::__depth__ .set ::__depth__ + 1
		.scope
		bmi .ident(.sprintf("__else__%d", ::__depth__))

	; LE (Less Than Or Equal To)
	.elseif (.xmatch (arg1, LE))

		::__depth__ .set ::__depth__ + 1
		.scope
		bne .ident(.sprintf("__else__%d", ::__depth__))
		bcs .ident(.sprintf("__else__%d", ::__depth__))

	; GT (Greater Than)
	.elseif (.xmatch (arg1, GT))

		::__depth__ .set ::__depth__ + 1
		.scope
		bcc .ident(.sprintf("__else__%d", ::__depth__))
		beq .ident(.sprintf("__else__%d", ::__depth__))

	; None of the above
	.else
	
		.fatal "Invalid comparison"
	
	.endif

.endmacro


.macro ELSE

	jmp .ident(.sprintf("__endif__%d", ::__depth__))
	.ident(.sprintf("__else__%d", ::__depth__)) := *

.endmacro


.macro END_IF

    .if .not(.defined(.ident(.sprintf("__else__%d", ::__depth__))))
        .ident(.sprintf("__else__%d", ::__depth__)) := *
    .endif

	.ident(.sprintf("__endif__%d", ::__depth__)) := *
	.refto .ident(.sprintf("__endif__%d", ::__depth__))

.endscope

    ::__depth__ .set ::__depth__ - 1

	.if ::__elseifcount__ > 0
		::__elseifcount__ .set ::__elseifcount__ - 1
		END_IF
	.endif

.endmacro


.macro ELSE_IF arg1, arg2, arg3
	::__elseifcount__ .set ::__elseifcount__ + 1
	ELSE
	IF arg1, arg2, arg3
.endmacro


.macro SWITCH arg1

	.if .not (.xmatch (arg1, A))
		lda arg1
	.endif

.endmacro


.macro CASE arg1

	.if (::__casedefined__ = 1)
		ELSE_IF A, EQ, arg1
	.endif

	.if (::__casedefined__ = 0)
		IF A, EQ, arg1
		::__casedefined__ .set 1
	.endif

.endmacro


.macro END_SWITCH
	::__casedefined__ .set 0

	END_IF
.endmacro


.macro DO

	::__depth__ .set ::__depth__ + 1
	.scope
	.ident(.sprintf("__do_loop__%d", ::__depth__)) := *

.endmacro


.macro WHILE arg1
	
	; EQ (Equal)
	.if (.xmatch (arg1, EQ))

		jeq .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; NE (Not Equal)
	.elseif (.xmatch (arg1, NE))

		jne .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; CC (Carry Clear / Less Than)
	.elseif (.xmatch (arg1, CC))

		jcc .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; CS (Carry Set / Greater Than Or Equal To)
	.elseif (.xmatch (arg1, CS))

		jcs .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; VC (Overflow Clear)
	.elseif (.xmatch (arg1, VC))

		jvc .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; VS (Overflow Set)
	.elseif (.xmatch (arg1, VS))

		jvs .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; MI (Negative Set / Negative)
	.elseif (.xmatch (arg1, MI))

		jmi .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; PL (Negative Clear / Positive)
	.elseif (.xmatch (arg1, PL))

		jpl .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; LE (Less Than Or Equal To)
	.elseif (.xmatch (arg1, LE))

		beq .ident(.sprintf("__do_loop__%d", ::__depth__))
		bcc .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; GT (Greater Than)
	.elseif (.xmatch (arg1, GT))

		beq :+
		bcs .ident(.sprintf("__do_loop__%d", ::__depth__))
		:
		.endscope
		::__depth__ .set ::__depth__ - 1

	; TRUE (Always)
	.elseif (.xmatch (arg1, TRUE))

		jmp .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; None of the above
	.else
	
		.fatal "Invalid comparison"
	
	.endif

.endmacro


.macro _for_inc_helper arg1, arg2

	.if (.xmatch (arg1, inx))
		inx
		.if (.xmatch (arg2, 2))
			inx
		.endif
		.if (.xmatch (arg2, 3))
			inx
			inx
		.endif
		.if (.xmatch (arg2, 4))
			inx
			inx
			inx
		.endif
		.exitmacro
	.endif

	.if (.xmatch (arg1, dex))
		dex
		.if (.xmatch (arg2, 2))
			dex
		.endif
		.if (.xmatch (arg2, 3))
			dex
			dex
		.endif
		.if (.xmatch (arg2, 4))
			dex
			dex
			dex
		.endif
		.exitmacro
	.endif

	.if (.xmatch (arg1, iny))
		iny
		.if (.xmatch (arg2, 2))
			iny
		.endif
		.if (.xmatch (arg2, 3))
			iny
			iny
		.endif
		.if (.xmatch (arg2, 4))
			iny
			iny
			iny
		.endif
		.exitmacro
	.endif

	.if (.xmatch (arg1, dey))
		dey
		.if (.xmatch (arg2, 2))
			dey
		.endif
		.if (.xmatch (arg2, 3))
			dey
			dey
		.endif
		.if (.xmatch (arg2, 4))
			dey
			dey
			dey
		.endif
		.exitmacro
	.endif

	.fatal "Invalid inc/dec operation"

.endmacro


.macro _for_helper arg1, arg2, arg3, arg4, arg5

	.if (.xmatch (arg1, X))

		_for_inc_helper arg4, arg5

		.if (.xmatch (arg3, #0)) .and (.xmatch (arg2, NE))
		.elseif (.xmatch (arg3, #$80)) .and (.xmatch (arg2, PL)) .and (.match (arg4, inx))
		.elseif (.xmatch (arg3, #$7f)) .and (.xmatch (arg2, MI)) .and (.match (arg4, dex))
		.elseif (.xmatch (arg3, #$ff)) .and (.xmatch (arg2, PL)) .and (.match (arg4, dex))
		.else
			cpx arg3
		.endif

	.elseif (.xmatch (arg1, Y))

		_for_inc_helper arg4, arg5

		.if (.xmatch (arg3, #0)) .and (.xmatch (arg2, NE))
		.elseif (.xmatch (arg3, #$80)) .and (.xmatch (arg2, PL)) .and (.match (arg4, iny))
		.elseif (.xmatch (arg3, #$7f)) .and (.xmatch (arg2, MI)) .and (.match (arg4, dey))
		.elseif (.xmatch (arg3, #$ff)) .and (.xmatch (arg2, PL)) .and (.match (arg4, dey))
		.else
			cpy arg3
		.endif

	.else

		.fatal "Invalid index register"

	.endif

.endmacro


; Register, Comparison, Value, Operation
.macro FOR arg1, arg2, arg3, arg4, arg5

	; EQ (Equal)
	.if (.xmatch (arg2, EQ))

		_for_helper arg1, arg2, arg3, arg4, arg5
		beq .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; NE (Not Equal)
	.elseif (.xmatch (arg2, NE))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bne .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; CC (Carry Clear / Less Than)
	.elseif (.xmatch (arg2, CC))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bcc .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; CS (Carry Set / Greater Than Or Equal To)
	.elseif (.xmatch (arg2, CS))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bcs .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; VC (Overflow Clear)
	.elseif (.xmatch (arg2, VC))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bvc .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; VS (Overflow Set)
	.elseif (.xmatch (arg2, VS))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bvs .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; MI (Negative Set / Negative)
	.elseif (.xmatch (arg2, MI))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bmi .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; PL (Negative Clear / Positive)
	.elseif (.xmatch (arg2, PL))

		_for_helper arg1, arg2, arg3, arg4, arg5
		bpl .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; LE (Less Than Or Equal To)
	.elseif (.xmatch (arg2, LE))

		_for_helper arg1, arg2, arg3, arg4, arg5
		beq .ident(.sprintf("__do_loop__%d", ::__depth__))
		bcc .ident(.sprintf("__do_loop__%d", ::__depth__))
		.endscope
		::__depth__ .set ::__depth__ - 1

	; GT (Greater Than)
	.elseif (.xmatch (arg2, GT))

		_for_helper arg1, arg2, arg3, arg4, arg5
		beq :+
		bcs .ident(.sprintf("__do_loop__%d", ::__depth__))
		:
		.endscope
		::__depth__ .set ::__depth__ - 1

	; None of the above
	.else
	
		.fatal "Invalid comparison"
	
	.endif

.endmacro


