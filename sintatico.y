%{
#include <iostream>
#include <string>
#include <vector>
#include <map>

#define YYSTYPE atributos

using namespace std;

int var_temp_qnt;
vector<pair<string, string>> temporarios;
int linha = 1;
string codigo_gerado;

struct atributos
{
	string label;
	string traducao;
	string tipo;
};


int yylex(void);

void yyerror(string);
string gentempcode(string tipo);
void declaraTemp();

%}

%token TK_NUM TK_FLOAT TK_ID TK_CHAR
%token INT FLOAT_TYPE CHAR DOUBLE
%token IF ELSE FOR WHILE RETURN
%token EQ NE LE GE
%token AND OR TK_BOOL

%start S

%left '+' '-'
%left '*' '/'

%%


S 			: E
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";

				declaraTemp();

				codigo_gerado += "\n";

				codigo_gerado += $1.traducao;

				codigo_gerado += "\treturn 0;"
							"\n}\n";
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS		: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO		: E ';'
			{
				$$.traducao = $1.traducao;
			}
			;

E 			: E '+' E
			{
				$$.tipo = $1.tipo;
				$$.label = gentempcode($1.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " + " + $3.label + ";\n";
			}
			
			| E '-' E
			{
				$$.tipo = $1.tipo;
				$$.label = gentempcode($1.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " - " + $3.label + ";\n";
			}
			| E '*' E
			{
				$$.tipo = $1.tipo;
				$$.label = gentempcode($1.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " * " + $3.label + ";\n";
			}
			| E '/' E
			{
				$$.tipo = $1.tipo;
				$$.label = gentempcode($1.tipo);
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " / " + $3.label + ";\n";
			}
			| '(' E ')'
			{
				$$.label = $2.label;
				$$.traducao = $2.traducao;
				$$.tipo = $2.tipo;
			}
			| TK_FLOAT
			{
				$$.tipo = "float";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_CHAR
			{
				$$.tipo = "char";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_BOOL
			{
				$$.tipo = "bool";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID '=' E
			{
				$$.tipo = $3.tipo;
				$$.label = $1.label;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{	
				$$.tipo = "int";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				$$.tipo = "int";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

void declaraTemp(){
	for (auto &t : temporarios) {
    codigo_gerado += "\t" + t.second + " " + t.first + ";\n";
	}
}

string gentempcode(string tipo)
{
	var_temp_qnt++;
	string nome =  "t" + to_string(var_temp_qnt);
	temporarios.push_back({nome, tipo});
	return nome;
}

int main(int argc, char* argv[])
{
	var_temp_qnt = 0;

	if (yyparse() == 0)
		cout << codigo_gerado;

	return 0;
}

void yyerror(string MSG)
{
	cerr << "Erro na linha " << linha << ": " << MSG << endl;
}