/* calc-code.l */
%option noyywrap nodefault
%{
    /* 一行内既有代码又有注释, 则codeno,commentno都加一 */
    int lineno = 0;        	/* 总行数 */
    int emptylineno = 0;	/* 空行数 */
    int codeno = 0;		/* 纯代码行数 */
    int commentno = 0;		/* 注释行数 */
    int comment_codeno = 0;	/* 代码注释混合行数 */

    int total_lines = 0;
    int total_emptylines = 0;
    int total_codelines = 0;
    int total_commentlines = 0;
    int total_comment_codelines = 0;

    int is_comment = 0;	    /* 该行是否为注释 */
    int in_comment = 0;	    /* 是否在注释内,主要考虑跨行的注释代码 */
    int is_code = 0;	    /* 该行是否为代码 */
%}

%%
^[ \t]*\/\/.*		{ is_comment = 1; }	
[^ \t\n]+[ \t]*\/\/	{ if (in_comment) is_comment = 1; else {is_comment = 1; is_code = 1;} }
\/\*			{ in_comment = 1; is_comment = 1; }
[^ \t\n]+[ \t]*\/\*     { in_comment = 1; is_comment = 1; is_code = 1;} 
\*\/			{ in_comment = 0; is_comment = 1; }
\*\/[ \t]*[^ \t\n]+     { in_comment = 0; is_comment = 1; is_code = 1; }
[^ \t\n]		{ if (in_comment) is_comment = 1; if( !is_comment ) is_code = 1; } /* 非空格字符 */
\n			{ /* 一行结束了,分析这行的属性 */
	lineno++;
	if (!is_comment && !is_code)
	    emptylineno++;
	else if (is_comment && is_code) {
	    commentno++;
	    codeno++;
	    comment_codeno++;
	} else {
	    if (is_comment)
		commentno++;
	    if (is_code)
		codeno++;
	}
	is_comment = 0;
	is_code = 0;
    }
.	    { ; } /* 匹配漏掉的字符,使它不输出 */
%%

int main(int argc, char **argv)
{
    int i;
    if( argc < 2 ) {
	yylex();
	if (is_comment && is_code) {
	    commentno++;
	    codeno++;
	    comment_codeno++;
	} else {
	    if (is_comment)	{
		lineno++;
		commentno++;
	    } else if (is_code) {
		lineno++;
		codeno++;
	    }
	}
	printf("\033[36;1m%s    %s      %s    %s      %s\033[0m\n","总行数","空行","纯代码","混合","纯注释");
	printf("%-10d%-10d%-10d%-10d%-10d\n",lineno,emptylineno,codeno - comment_codeno,comment_codeno,commentno - comment_codeno);
	return 0;
    }

    printf("\033[36;1m%s    %s      %s    %s      %s\033[0m\n","总行数","空行","纯代码","混合","纯注释");
    for(i = 1; i < argc; i++) {
	FILE *f = fopen(argv[i], "r");
	if(!f) {
	    perror(argv[i]);
	    return 1;
	}
	yyrestart(f);
	yylex();
	fclose(f);
  
	if (is_comment && is_code) {
	    commentno++;
	    codeno++;
	    comment_codeno++;
	} else {
	    if (is_comment)	{
		lineno++;
		commentno++;
	    } else if (is_code) {
		lineno++;
		codeno++;
	    }
	}
	printf("%-10d%-10d%-10d%-10d%-10d - \033[34;1m%s\033[0m\n",lineno,emptylineno,codeno - comment_codeno,comment_codeno,commentno - comment_codeno, argv[i]);
	total_lines += lineno; lineno = 0;
	total_emptylines += emptylineno; emptylineno = 0;
	total_codelines += codeno; codeno = 0;
	total_commentlines += commentno; commentno = 0;
	total_comment_codelines += comment_codeno; comment_codeno = 0;
    }
    
    if(argc > 2)
	printf("%-10d%-10d%-10d%-10d%-10d - \033[34;1mtotal\033[0m\n",total_lines,total_emptylines,total_codelines - total_comment_codelines, total_comment_codelines, total_commentlines - total_comment_codelines );
    return 0;
}
