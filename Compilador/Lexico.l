%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
    #include <stdbool.h>
	#include "y.tab.h"
	#include <string.h>
	#include <float.h>	
	#include "funciones.c"
    
%}
%option noyywrap
%option yylineno 

NEGATIVO				"-"
DIGITO			        [0-9]
LETRA			        [a-zA-Z]
CONST_STR               \"({DIGITO}|{LETRA}|.)*\"
CADENA                  ({LETRA}|{DIGITO}|\.|\:|\;\-|\_|\!|_|" "|\n|\s|\t|\r|\@|\%\º)*
COMENTARIOS             (--\/){CADENA}(\/\--)|(--\/){CADENA}(--\/){CADENA}(\/\--){CADENA}(\/\--)|(--\/)(--\/){CADENA}(\/\--){CADENA}(\/\--)|(--\/){CADENA}(\/\--){CADENA}(\/\--)(\/\--)
CONST_REAL              {NEGATIVO}?{DIGITO}*"."{DIGITO}+|{NEGATIVO}?{DIGITO}+"."{DIGITO}*
CONST_INT               {NEGATIVO}?{DIGITO}+
ID			            {LETRA}({LETRA}|{DIGITO}|_)*
OP_ASIG   		        [":="]

%%
"var"		            { return VAR;}
"endvar"		        { return ENDVAR;}
"float"		            { return REAL;}
"int"		            { return INTEGER;}
"string"		        { return STRING;}
"if"			        { return IF;}
"else"   		        { return ELSE;}
"repeat"			    { return REPEAT;}
"until"			        { return UNTIL;}
"inlist"			    { return INLIST;}
"read"			        { return READ;}
"print" 			    { return PRINT;}
":="			        { return OP_ASIG;}
"+"			            { return OP_SUM;}
"-"			            { return OP_RES;}
"*"			            { return OP_MUL;}
"/"			            { return OP_DIV;}
"("			            { return P_A;}
")"			            { return P_C;}
"["                     { return C_A;}
"]"                     { return C_C;}
"{"                     { return L_A;}
"}"                     { return L_C;}
">"						{ return CMP_MAYOR; }
">="					{ return CMP_MAYIG; }
"!="					{ return CMP_DIST; }
"=="					{ return CMP_IGUAL;}
"<"						{ return CMP_MENOR; }
"<="					{ return CMP_NENIG; }
"and"                   { return OP_AND;}
"or"                    { return OP_OR;}
"not"                   { return OP_NOT;}
{ID}			        { yylval.str_val = strdup(yytext); insertarEnTablaDeSimbolos(sinTipo,yytext,yylineno); return ID;}
{CONST_INT}		        { yylval.str_val = strdup(yytext); insertarEnTablaDeSimbolos(tipoConstEntero,yytext,yylineno); return CONST_INT;}//lo manejo como string cambiar despues 
{CONST_STR}		        { yylval.str_val = strdup(yytext); insertarEnTablaDeSimbolos(tipoConstCadena,yytext,yylineno); return CONST_STR;}
{CONST_REAL}		    { yylval.str_val = strdup(yytext); insertarEnTablaDeSimbolos(tipoConstReal,yytext,yylineno); return CONST_REAL;}
","		           		{ return COMA;}
":"						{ return DOS_PUNTOS;}
";"						{ return PUNTO_Y_COMA;}
<<EOF>> 				{createSymbolTable(yylineno); yyterminate();}
"\n"
"\r\n"
"\t"
" "
{COMENTARIOS} 
. 						{ mensajeDeError(errorCaracterInvalido,yytext,yylineno);}	

%%
