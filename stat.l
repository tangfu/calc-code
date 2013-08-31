/* stat.c */
%option noyywrap
%{
#include <stdio.h>
/* 一行内既有代码又有注释, 则codeno,commentno都加一 */
int lineno = 0;        /* 总行数 */
int emptylineno = 0;    /* 空行数 */
int codeno = 0;        /* 代码行数 */
int commentno = 0;    /* 注释行数 */
int is_comment = 0;    /* 该行是否为注释 */
int in_comment = 0;    /* 是否在注释内,主要考虑跨行的注释代码 */
int is_code = 0;    /* 该行是否为代码 */
%}

%%
\/\/        { is_comment = 1; } /* 匹配以//开始的注释 */
\/\*        { in_comment = 1; is_comment = 1; } /* 匹配另一种注释 */
\*\/        { in_comment = 0; is_comment = 1; }
[^ \t\n]    { if (in_comment) is_comment = 1; else is_code = 1; } /* 非空格字符 */
\n    { /* 一行结束了,分析这行的属性 */
        lineno++;
        if (!is_comment && !is_code)
            emptylineno++;
        else
        {
            if (is_comment)
                commentno++;
            if (is_code)
                codeno++;
        }
        is_comment = 0;
        is_code = 0;
    }
.    { ; } /* 匹配漏掉的字符,使它不输出 */
%%

int main()
{
    yylex();
    /* 匹配最后一行 */

    if  (is_comment)
    {
        lineno++;
         commentno++;
    }
    else if  (is_code)
    {
        lineno++;
        codeno++;
    }

    printf("%d\t%d\t%d\t%d\n", lineno, emptylineno, commentno, codeno);
    return 0;
}