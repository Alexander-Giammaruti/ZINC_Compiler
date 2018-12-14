%option noinput nounput
%option noyywrap


%{
#include <math.h>
#include <stdio.h>
#include "ZINC.tab.h"
#include "SymTab.h"

int lineNum = 0;
int pastBegin = 0;

FILE *inFile = NULL;



%}

delim	[ \t]
ws	{delim}*
comment --.*
ident	[A-Z][_A-Z0-9]*
num	[+-]?[1-9][0-9]*|0

%%
[\n]		{lineNum++;}
{ws}		;
"if"		{return IFSYM;}
"then"		{return THENSYM;}
"else" 		{return ELSESYM;}
"begin"		{pastBegin = 1; return BEGINSYM;}
"end"		{return ENDSYM;}
"endif"		{return ENDIFSYM;}
"endwhile"	{return ENDWHILESYM;}
"while"		{return WHILESYM;}
"loop"		{return LOOPSYM;}
"program"	{return PROGRAMSYM;}
"var"		{return VARSYM;}
"integer"	{return INTSYM; }
"writeInt"	{return WRITEINT;}
"readInt"	{return READINT;}
"(" 		{return LP;}
")" 		{return RP;}
":="		{return ASGN;}
";"		{return SC;}
":"		{return COLON;}
"**"		{return POWSYM;}
"*"		{return MULSYM;}
"div"		{return DIVSYM;}
"mod"		{return MODSYM;}
"+"		{return PLUSSYM;}
"-"		{return MINUSSYM;}
"="		{return EQ;}
"<>"		{return NE;}
"<"		{return LT;}
">"		{return GT;}
"<="		{return LE;}
">="		{return GE;}
{comment}	;
{num}		{yylval = strdup(yytext); return NUM;}
{ident}		{yylval = strdup(yytext); performSearch(yytext, lineNum, pastBegin); return ID;}		
[a-z][a-zA-Z0-9]*	{printf("ERROR: unrecognized token (possible capitalization error): %s at line %d\n", yytext, lineNum);}
.		{printf("ERROR: Unrecognized symbol: %s at line %d\n", yytext, lineNum);}
%%

