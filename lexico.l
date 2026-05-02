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
"bool"   return BOOL_TYPE;
"true"   { yylval.label = "1"; return TK_BOOL; }
"false"  { yylval.label = "0"; return TK_BOOL; }

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


{ID}        { yylval.label = yytext; return TK_ID; }

\n          { linha++; }

.           { printf("Erro na linha %d: %s\n", linha, yytext); }

%%