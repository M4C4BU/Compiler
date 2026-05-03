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

struct Simbolo {
    string tipo;
    string temp;
};

map<string,Simbolo> tabela_simbolos;

int yylex(void);

void yyerror(string);
string gentempcode(string tipo);
void declaraTemp();

string maior_tipo(string t1, string t2) {
    if (t1 == "float" || t2 == "float") return "float";
    if (t1 == "int"   || t2 == "int")   return "int";
    return "char";
}

string converter(string origem, string destino, string label, string &traducao) {
    if (origem == destino) return label;
    string temp = gentempcode(destino);
    traducao += "\t" + temp + " = (" + destino + ") " + label + ";\n";
    return temp;
}

%}

%token TK_NUM TK_FLOAT TK_ID TK_CHAR 
%token INT FLOAT_TYPE CHAR DOUBLE BOOL_TYPE
%token IF ELSE FOR WHILE RETURN
%token EQ NE LE GE
%token AND OR TK_BOOL
%token NOT

%start S

%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'
%right NOT

%%


S 			: E
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";

				declaraTemp();

				codigo_gerado += "\n";
				codigo_gerado += $1.traducao;
				codigo_gerado += "\treturn 0;\n}\n";
			}
			| COMANDOS
			{
				codigo_gerado = "/*Compilador FOCA*/\n"
								"#include <stdio.h>\n"
								"int main(void) {\n";

				declaraTemp();

				codigo_gerado += "\n";
				codigo_gerado += $1.traducao;
				codigo_gerado += "\treturn 0;\n}\n";
			}
			;

COMANDOS 	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			| COMANDO
			{
				$$.traducao = $1.traducao;
			}
			;

COMANDO 	: DECL ';'
			{
				$$.traducao = $1.traducao;
			}
			| TK_ID '=' E ';'
			{
				if(!tabela_simbolos.count($1.label))
				{
					tabela_simbolos[$1.label].tipo = $3.tipo;
					tabela_simbolos[$1.label].temp = "";
				}
				else if(tabela_simbolos[$1.label].tipo != $3.tipo)
				{
					yyerror("Tipos incompativeis na atribuicao");
				}

				if(tabela_simbolos[$1.label].temp == "")
					tabela_simbolos[$1.label].temp = gentempcode(tabela_simbolos[$1.label].tipo);

				$$.traducao =
					$3.traducao +
					"\t" + tabela_simbolos[$1.label].temp +
					" = " + $3.label + ";\n";
			}
			| TK_ID '=' E
			{
				if(!tabela_simbolos.count($1.label))
				{
					tabela_simbolos[$1.label].tipo = $3.tipo;
					tabela_simbolos[$1.label].temp = "";
				}
				else if(tabela_simbolos[$1.label].tipo != $3.tipo)
				{
					yyerror("Tipos incompativeis na atribuicao");
				}

				if(tabela_simbolos[$1.label].temp == "")
					tabela_simbolos[$1.label].temp = gentempcode(tabela_simbolos[$1.label].tipo);

				$$.traducao =
					$3.traducao +
					"\t" + tabela_simbolos[$1.label].temp +
					" = " + $3.label + ";\n";
			}
			;

DECL		: TIPO TK_ID
			{
				if(tabela_simbolos.count($2.label))
					yyerror("Variavel ja declarada");

				tabela_simbolos[$2.label].tipo = $1.tipo;
				tabela_simbolos[$2.label].temp = "";

				$$.traducao = "";
			}
			;

TIPO		: INT
			{
				$$.tipo = "int";
			}
			| FLOAT_TYPE
			{
				$$.tipo = "float";
			}
			| CHAR
			{
				$$.tipo = "char";
			}
			| BOOL_TYPE
			{
				$$.tipo = "int";
			}
			;

E 			: E '+' E
			{
				string t = maior_tipo($1.tipo, $3.tipo);
				string trad1 = $1.traducao, trad2 = $3.traducao;
				string l1 = converter($1.tipo, t, $1.label, trad1);
				string l2 = converter($3.tipo, t, $3.label, trad2);
				$$.tipo = t;
				$$.label = gentempcode(t);
				$$.traducao = trad1 + trad2 +
					"\t" + $$.label + " = " + l1 + " + " + l2 + ";\n";
			}
			| E '-' E
			{
				string t = maior_tipo($1.tipo, $3.tipo);
				string trad1 = $1.traducao, trad2 = $3.traducao;
				string l1 = converter($1.tipo, t, $1.label, trad1);
				string l2 = converter($3.tipo, t, $3.label, trad2);
				$$.tipo = t;
				$$.label = gentempcode(t);
				$$.traducao = trad1 + trad2 +
					"\t" + $$.label + " = " + l1 + " - " + l2 + ";\n";
			}
			| E '*' E
			{
				string t = maior_tipo($1.tipo, $3.tipo);
				string trad1 = $1.traducao, trad2 = $3.traducao;
				string l1 = converter($1.tipo, t, $1.label, trad1);
				string l2 = converter($3.tipo, t, $3.label, trad2);
				$$.tipo = t;
				$$.label = gentempcode(t);
				$$.traducao = trad1 + trad2 +
					"\t" + $$.label + " = " + l1 + " * " + l2 + ";\n";
			}
			| E '/' E
			{
				string t = maior_tipo($1.tipo, $3.tipo);
				string trad1 = $1.traducao, trad2 = $3.traducao;
				string l1 = converter($1.tipo, t, $1.label, trad1);
				string l2 = converter($3.tipo, t, $3.label, trad2);
				$$.tipo = t;
				$$.label = gentempcode(t);
				$$.traducao = trad1 + trad2 +
					"\t" + $$.label + " = " + l1 + " / " + l2 + ";\n";
			}
			| E '<' E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " < " + $3.label + ";\n";
			}
			| E '>' E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " > " + $3.label + ";\n";
			}
			| E LE E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " <= " + $3.label + ";\n";
			}
			| E GE E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " >= " + $3.label + ";\n";
			}
			| E EQ E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " == " + $3.label + ";\n";
			}
			| E NE E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " != " + $3.label + ";\n";
			}
			| E AND E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " && " + $3.label + ";\n";
			}
			| E OR E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label +
					" = " + $1.label + " || " + $3.label + ";\n";
			}
			| NOT E
			{
				$$.tipo = "int";
				$$.label = gentempcode("int");
				$$.traducao = $2.traducao + "\t" + $$.label +
					" = !" + $2.label + ";\n";
			}
			| '(' TIPO ')' E
			{
				string temp_copia = gentempcode($4.tipo);
				string temp_cast  = gentempcode($2.tipo);
				$$.tipo  = $2.tipo;
				$$.label = temp_cast;
				$$.traducao = $4.traducao +
					"\t" + temp_copia + " = " + $4.label + ";\n" +
					"\t" + temp_cast  + " = (" + $2.tipo + ") " + temp_copia + ";\n";
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
				$$.label = $1.label;
				$$.traducao = "";
			}
			| TK_BOOL
			{
				$$.tipo = "int";
				$$.label = $1.label;
				$$.traducao = "";
			}
			| TK_NUM
			{	
				$$.tipo = "int";
				$$.label = gentempcode($$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
			}
			| TK_ID
			{
				if(!tabela_simbolos.count($1.label))
				{
					tabela_simbolos[$1.label].tipo = "int";
					tabela_simbolos[$1.label].temp = "";
				}

				if(tabela_simbolos[$1.label].temp == "")
					tabela_simbolos[$1.label].temp = gentempcode(tabela_simbolos[$1.label].tipo);

				$$.tipo = tabela_simbolos[$1.label].tipo;
				$$.label = tabela_simbolos[$1.label].temp;
				$$.traducao = "";
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
	string nome = "t" + to_string(var_temp_qnt);
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
