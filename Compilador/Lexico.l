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

DIGITO			        [0-9]
LETRA			        [a-zA-Z]
COMA                    [","]
PUNTOYCOMA              [";"]
CONST_STR               \"({DIGITO}|{LETRA}|.)*\"
COMENTARIOS             (-\/).*(\/\-)
CONST_REAL              {DIGITO}*"."{DIGITO}*
CONST_INT               {DIGITO}+
ID			            {LETRA}({LETRA}|{DIGITO}|_)*
OP_ASIG   		        [":="]
C_A                     ["["]
C_C                     ["]"]
P_A                     ["("]
P_C                     [")"]


%%
"var"		            { return VAR;}
"endvar"		        { return ENDVAR;}
"float"		            { return REAL;}
"int"		            { return INTEGER;}
"string"		        { return STRING;}
"if"			        { return IF;}
"else"   		        { return ELSE;}
"endif"	                { return ENDIF;}
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
">"						{ return CMP_MAYOR; }
">="					{ return CMP_MAYIG; }
"!="					{ return CMP_DIST; }
"=="					{ return CMP_IGUAL;}
"<"						{ return CMP_MENOR; }
"<="					{ return CMP_NENIG; }
"and"                   { return OP_AND;}
"or"                    { return OP_OR;}
"not"                   { return OP_NOT;}
{ID}			        { yylval.str_val = strdup(yytext); return ID;}
{CONST_INT}		        { yylval.str_val = strdup(yytext); return CONST_INT;}//lo manejo como string cambiar despues 
{CONST_STR}		        { yylval.str_val = strdup(yytext); return CONST_STR;}
{CONST_REAL}		    { yylval.str_val = strdup(yytext); return CONST_REAL;}
{COMA}		            { return COMA;}
":"						{ return DOS_PUNTOS;}
<<EOF>> 				{ yyterminate();}
"\n"
"\r\n"
"\t"
" "
{COMENTARIOS} 
. 						{ mensajeDeError(errorCaracterInvalido,yytext,yylineno);}	

%%