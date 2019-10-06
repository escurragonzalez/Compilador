%{
//INCLUDES//
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#include "stack.c"
#include "queue.c"
//#define YYDEBUG 1 //tener cuidado con este flag mas adelante con las referencias a otros archivos c no funciona

m10_stack_t *stVariables;
t_queue qVariables;
t_queue qPolaca;
extern int yylineno;
FILE *yyin;
char *yyltext;
char *yytext;
char aux_str[30];
//yydebug = 1; //tener cuidado con el flag no funciona mas adelante sacarlo

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
%token IF ELSE
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

prorama:   bloq_decla bloque

bloq_decla: VAR declaraciones ENDVAR

declaraciones:  declaracion
			| declaraciones declaracion;

declaracion: C_A dec_multiple C_C

dec_multiple: 	lista_tipo_dato C_C DOS_PUNTOS C_A lista_id 

lista_tipo_dato: tipo_dato 
				| tipo_dato COMA lista_tipo_dato

lista_id: ID
			{
				if(!is_queue_empty(&qVariables)) 
				{
					dequeue(&qVariables,aux_str);
					asignarTipo($1,aux_str,yylineno);
				}
			}
		| lista_id COMA ID
			{
				if(!is_queue_empty(&qVariables)) 
				{
					dequeue(&qVariables,aux_str);
					asignarTipo($3,aux_str,yylineno);
				}
			}

tipo_dato: 	REAL	{ enqueue(&qVariables,"float"); } 
			| STRING	{ enqueue(&qVariables,"string"); } 
			| INTEGER	{ enqueue(&qVariables,"int"); } 

bloque: 	sentencia 
			| bloque sentencia 

sentencia:	ciclo
			| seleccion 
			| asignacion
			| intout							

intout: 	PRINT  CONST_STR
			{
				enqueue(&qPolaca, $2);
				enqueue(&qPolaca, "PRINT");					
			}
	    	| READ  ID  
			{ 
				verificarExisteId($2,yylineno);
				enqueue(&qPolaca, $2);
				enqueue(&qPolaca, "READ");	
			}
			| PRINT  ID
			{
				verificarExisteId($2,yylineno);
				enqueue(&qPolaca, $2);
				enqueue(&qPolaca, "PRINT");	
			}
		
ciclo:	REPEAT bloque 
		UNTIL P_A condicion P_C 
		
asignacion: 	ID OP_ASIG expresion 
				{
					verificarExisteId($1,yylineno);
					enqueue(&qPolaca, $1);
					enqueue(&qPolaca, ":=");
				}

seleccion:  condicion_if bloque L_C 
            | condicion_if bloque L_C ELSE L_A bloque L_C
                        
condicion_if: IF P_A condicion P_C L_A

condicion:		comparacion  
			| comparacion OP_AND comparacion 
			| comparacion OP_OR comparacion 
			| OP_NOT comparacion 
			
comparacion:	expresion CMP_MAYOR expresion
			|	expresion CMP_MAYIG expresion
			|	expresion CMP_DIST expresion
			|	expresion CMP_IGUAL expresion
			|	expresion CMP_MENOR expresion
			|	expresion CMP_NENIG expresion
            |	f_inlist


expresion:		termino
		| expresion OP_SUM termino { enqueue(&qPolaca,"+"); }
		| expresion OP_RES termino { enqueue(&qPolaca,"-"); }

termino: 		factor 
		| termino OP_MUL  factor { enqueue(&qPolaca,"*"); }
    	| termino OP_DIV  factor { enqueue(&qPolaca,"/"); }


factor:     ID 
			{ 
				verificarExisteId($1,yylineno);
				enqueue(&qPolaca,$1);
			}
			| CONST_INT { enqueue(&qPolaca,$1); }
			| CONST_REAL { enqueue(&qPolaca,$1); }
			| CONST_STR { enqueue(&qPolaca,$1); }
			| P_A expresion P_C

f_inlist: INLIST P_A ID PUNTO_Y_COMA C_A lista_expresion C_C P_C

lista_expresion:  expresion
            | lista_expresion PUNTO_Y_COMA expresion

%%

int main(int argc,char *argv[])
{
	stVariables = newStack();
	init_queue(&qVariables);
	init_queue(&qPolaca);
    if ((yyin = fopen(argv[1], "rt")) == NULL)
    {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else
    {
        yyparse();
    }
    fclose(yyin);
	//Acá escribir el archivo intermedia.txt con lo que esta en en qPolaca
	print_queue(&qPolaca);
	destroyStack(&stVariables);
	free_queue(&qVariables);
	free_queue(&qPolaca);
    printf("\n\n* COMPILACION EXITOSA *\n");
	return 0;
}

int yyerror()
{
	printf("Error sintatico \n");
	system("Pause");
	exit(1);
}

