%{
#include "y.tab.h"
#include <string>
#include <stdio.h>

%}

%option noyywrap


ESPACO     [ \t]
LETRA      [a-zA-Z_]
DIGITO     [0-9]

ID         {LETRA}({LETRA}|{DIGITO})*
NUM        {DIGITO}+
FLOAT      {DIGITO}+\.{DIGITO}*([eE][+-]?{DIGITO}+)?

%%

{ESPACO}+   { }
"//".*      { }
"/*"([^*]|\*+[^*/])*\*+"/"   { }


"int"       { return INT; }
"float"     { return FLOAT_TYPE; }
"char"      { return CHAR; }
"double"    { return DOUBLE; }

"if"        { return IF; }
"else"      { return ELSE; }
"for"       { return FOR; }
"while"     { return WHILE; }
"return"    { return RETURN; }


"=="        { return EQ; }
"!="        { return NE; }
"<="        { return LE; }
">="        { return GE; }

"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }

"<"         { return '<'; }
">"         { return '>'; }
"="         { return '='; }


"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }
";"         { return ';'; }
","         { return ','; }

"&&"        { return AND; }
"||"        { return OR; }
"!"         { return '!'; }


{FLOAT}     { yylval.label = yytext; return TK_FLOAT; }
{NUM}       { yylval.label = yytext; return TK_NUM; }
\'({LETRA}|{NUM})\' { yylval.label = yytext; return TK_CHAR; }

"true"  { yylval.label = yytext; return TK_BOOL; }
"false" { yylval.label = yytext; return TK_BOOL; }

{ID}        { yylval.label = yytext; return TK_ID; }

\n          { linha++; }

.           { printf("Erro na linha %d: %s\n", linha, yytext); }

%%