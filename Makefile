ALL:	calc-code.l stat.l
	flex calc-code.l
	cc lex.yy.c -o calc-code
	flex stat.l
	cc lex.yy.c -o stat