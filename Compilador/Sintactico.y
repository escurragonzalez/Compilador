%{
//INCLUDES//
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#define YYDEBUG 1 //tener cuidado con este flag mas adelante con las referencias a otros archivos c no funciona

extern int yylineno;
FILE *yyin;
char *yyltext;
char *yytext;
yydebug = 0; //tener cuidado con el flag no funciona mas adelante sacarlo

%}

%union {
	int entero;
	double real;
	char *str_val;
	char oper;
}

%token VAR ENDVAR
%token <str_val>CONST_INT //cambiar despues 
%token <str_val>CONST_REAL
%token <str_val>CONST_STR
%token REAL
%token INTEGER
%token STRING
%token BEGINP
%token IF THEN ELSE ENDIF
%token REPEAT UNTIL
%token INLIST
%token OP_AND OP_OR OP_NOT
%token OP_NEG
%token <str_val>ID
%token OP_COMPARACION
%token CMP_MAYOR CMP_MAYIG CMP_DIST CMP_IGUAL CMP_MENOR CMP_NENIG
%token OP_ASIG
%token OP_SUM
%token OP_RES
%token OP_MUL
%token OP_DIV
%token COMA
%token DOS_PUNTOS
%token P_A P_C
%token C_A C_C
%token L_A L_C
%token PUNTO_Y_COMA
%token PRINT
%token READ

%%

// Sacar los printf despues 
prorama:   bloq_decla bloque { printf("start sysbol \n");}

bloq_decla: VAR declaraciones ENDVAR { printf("bloq_decla \n");}

declaraciones:  declaracion
			| declaraciones declaracion;

declaracion: C_A dec_multiple C_C

dec_multiple: 	tipo_dato C_C DOS_PUNTOS C_A ID
				| tipo_dato COMA dec_multiple COMA ID

tipo_dato: 	REAL
			| STRING
			| INTEGER

bloque: 	sentencia 
			| bloque sentencia 

sentencia:	ciclo
			| seleccion 
			| asignacion
			| intout							

intout: 	PRINT  CONST_STR { printf("PRINT \n");}
	    	| READ  ID  { printf("READ \n");}
			| PRINT  ID { printf("PRINT \n");}
		
ciclo:	REPEAT bloque 
		UNTIL P_A condicion P_C { printf("REPEAT \n");}
		
asignacion: 	ID OP_ASIG expresion { printf("asignacion \n");}

seleccion:  condicion_if bloque L_C ENDIF
            | condicion_if bloque L_C ELSE L_A bloque L_C ENDIF
                        
condicion_if: IF P_A condicion P_C THEN L_A

condicion:		comparacion  
			| comparacion OP_AND comparacion 
			| comparacion OP_OR comparacion 
			| OP_NEG comparacion 
            | f_inlist //revisar despues
			
comparacion:	expresion CMP_MAYOR expresion
			|	expresion CMP_MAYIG expresion
			|	expresion CMP_DIST expresion
			|	expresion CMP_IGUAL expresion
			|	expresion CMP_MENOR expresion
			|	expresion CMP_NENIG expresion

expresion:		termino
		| expresion OP_SUM termino 
		| expresion OP_RES termino

termino: 		factor 
		| termino OP_MUL  factor
    	| termino OP_DIV  factor 


factor:     ID 
			| CONST_INT  
			| CONST_REAL 
			| CONST_STR 

f_inlist: INLIST P_A ID PUNTO_Y_COMA C_A lista_expresion C_C P_C

lista_expresion:  ID
            | lista_expresion PUNTO_Y_COMA ID

%%

int main(int argc,char *argv[])
{
    if ((yyin = fopen(argv[1], "rt")) == NULL)
    {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else
    {
        yyparse();
    }
    fclose(yyin);
    printf("\n\n* COMPILACION EXITOSA *\n");
	return 0;
}

int yyerror()
{
	printf("Error sintatico \n");
	system("Pause");
	exit(1);
}

