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
m10_stack_t *stack_pos;		// pila por polaca
t_queue qVariables;
t_queue qVariablesAsig;
t_queue qPolaca;
extern int yylineno;
FILE *yyin;
char *yyltext;
char *yytext;
char aux_str[30];
int esAsig=0;
int contadorIf=0;		//contador por polaca 
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

dec_multiple: 	lista_tipo_dato C_C DOS_PUNTOS { esAsig=0; } C_A lista_id 

lista_tipo_dato: tipo_dato 
				| tipo_dato COMA lista_tipo_dato

lista_id: ID
			{
				//Declaracion de variables
				if(!is_queue_empty(&qVariables) && !esAsig) 
				{
					dequeue(&qVariables,aux_str);
					asignarTipo($1,aux_str,yylineno);
				}
				//Asignacion de variables
				if(esAsig)
				{
					verificarExisteId($1,yylineno);
					enqueue(&qVariablesAsig,$1);
				}
			}
		| lista_id COMA ID
			{
				//Declaracion de variables
				if(!is_queue_empty(&qVariables) && !esAsig) 
				{
					dequeue(&qVariables,aux_str);
					asignarTipo($3,aux_str,yylineno);
				}
				//Asignacion de variables
				if(esAsig)
				{
					verificarExisteId($3,yylineno);
					enqueue(&qVariablesAsig,$3);
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
				| asignacion_multiple

asignacion_multiple: C_A { esAsig=1; } lista_id C_C OP_ASIG C_A lista_expresion C_C { esAsig=0; }

seleccion:  condicion_if bloque L_C 
            | condicion_if bloque L_C ELSE { //bloque de polaca
				char aux2[20]; 
				sprintf(aux2,"#elseif_%s",top(stack_pos)); 
				pop(stack_pos); 
				enqueue(&qPolaca, aux2);
				} L_A bloque L_C
                        
condicion_if: IF { //bloque de polaca
				char auxif[10];
				contadorIf++;
				sprintf(auxif, "#if_%d", contadorIf);
				sprintf(aux_str, "%d", contadorIf);
				push(stack_pos, aux_str);
				enqueue(&qPolaca, auxif);
			}
			  P_A condicion P_C { //bloque de polaca
				char aux[10];
				sprintf(aux, "#thenif_%s", top(stack_pos));
				enqueue(&qPolaca, aux);
			}
			  L_A

condicion:	comparacion  
			| comparacion OP_AND comparacion	{ enqueue(&qPolaca, "and"); }
			| comparacion OP_OR comparacion 	{ enqueue(&qPolaca, "or"); }
			| OP_NOT comparacion 				{ enqueue(&qPolaca, "not"); }
			
comparacion:	expresion CMP_MAYOR expresion	{ char expr[4];  sprintf(expr, "%s", obtenerSalto(">")); enqueue(&qPolaca, "CMP");  enqueue(&qPolaca, expr); }
			|	expresion CMP_MAYIG  expresion	{ char expr[4];  sprintf(expr, "%s", obtenerSalto(">=")); enqueue(&qPolaca, "CMP"); enqueue(&qPolaca, expr); }
			|	expresion CMP_DIST expresion	{ char expr[4];  sprintf(expr, "%s", obtenerSalto("!=")); enqueue(&qPolaca, "CMP"); enqueue(&qPolaca, expr); }
			|	expresion CMP_IGUAL expresion	{ char expr[4];  sprintf(expr, "%s", obtenerSalto("==")); enqueue(&qPolaca, "CMP"); enqueue(&qPolaca, expr); }
			|	expresion CMP_MENOR expresion	{ char expr[4];  sprintf(expr, "%s", obtenerSalto("<")); enqueue(&qPolaca, "CMP");  enqueue(&qPolaca, expr); }
			|	expresion CMP_NENIG expresion	{ char expr[4];  sprintf(expr, "%s", obtenerSalto("<=")); enqueue(&qPolaca, "CMP"); enqueue(&qPolaca, expr); }
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
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					enqueue(&qPolaca,$1);
				}
			}
			| CONST_INT 
			{ 
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					enqueue(&qPolaca,$1);
				}
			}
			| CONST_REAL 
			{ 
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					enqueue(&qPolaca,$1);
				}
			}
			| CONST_STR 
			{
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					enqueue(&qPolaca,$1);
				}	
			}
			| P_A expresion P_C

f_inlist: INLIST P_A ID {enqueue(&qPolaca,$3);enqueue(&qPolaca,"=");} PUNTO_Y_COMA C_A lista_expresion C_C P_C

lista_expresion:  expresion
			{
				if(esAsig && !is_queue_empty(&qVariablesAsig))
				{
					dequeue(&qVariablesAsig,aux_str);
					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,":=");
				}
			}
            | lista_expresion PUNTO_Y_COMA expresion
            | lista_expresion COMA expresion
			{
				//Es por la asignacion multiple se tiene que ignorar en el caso que sobren expresiones
				//Ej [a,b]:=[1,2,2,2,2,2,2]
				if(esAsig && !is_queue_empty(&qVariablesAsig))
				{
					dequeue(&qVariablesAsig,aux_str);
					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,":=");
				}
			}

%%

int main(int argc,char *argv[])
{
	stVariables = newStack();
	stack_pos = newStack();	//inicia por polaca
	init_queue(&qVariables);
	init_queue(&qVariablesAsig);
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
	print_file_queue(&qPolaca);//Archivo intermedia.txt
	print_queue(&qPolaca);//Muestra polaca por consola
	destroyStack(&stVariables);
	destroyStack(&stack_pos); 		// destruye por polaca
	free_queue(&qVariables);
	free_queue(&qVariablesAsig);
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

