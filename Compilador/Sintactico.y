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
int contCondicion=0;		//contador por polaca 
char auxEtiquetas[10];
int auxOperaciones=0;

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
		
ciclo:	REPEAT 
		{
			contCondicion++;
			sprintf(auxEtiquetas, "#repeat_%d:", contCondicion);
			sprintf(aux_str, "%d", contCondicion);
			push(stack_pos, aux_str);
			enqueue(&qPolaca,auxEtiquetas);
			sprintf(auxEtiquetas, "#bloq_%d:", contCondicion);
			enqueue(&qPolaca,auxEtiquetas);
		} bloque 
		UNTIL P_A condicion P_C 
		{
			invertirSalto(&qPolaca);
			sprintf(aux_str,"#repeat_%s",top(stack_pos));
			enqueue(&qPolaca, aux_str);
			
			sprintf(aux_str,"#fin_%s:",top(stack_pos));
			enqueue(&qPolaca, aux_str);
			pop(stack_pos);
		}
		
asignacion: 	ID OP_ASIG expresion 
				{
					verificarExisteId($1,yylineno);
					enqueue(&qPolaca, $1);
					enqueue(&qPolaca, "=");
				}
				| asignacion_multiple

asignacion_multiple: C_A { esAsig=1; } lista_id C_C OP_ASIG C_A lista_expresion C_C { esAsig=0; }

seleccion:  condicion_if bloque L_C 
				{
					sprintf(aux_str,"#fin_%s:",top(stack_pos));
					enqueue(&qPolaca, aux_str);
					pop(stack_pos);
				}
            | condicion_if bloque L_C 
			{
				sprintf(aux_str,"#jmp fin_%s",top(stack_pos));
				enqueue(&qPolaca, aux_str);
			}
			ELSE { 
				sprintf(auxEtiquetas,"#elseif_%s:",top(stack_pos)); 
				enqueue(&qPolaca, auxEtiquetas);
				} 
				L_A bloque L_C
				{
					sprintf(aux_str,"#fin_%s:",top(stack_pos));
					enqueue(&qPolaca, aux_str);
					pop(stack_pos);
				}
                        
condicion_if: IF { 
				contCondicion++;
				sprintf(aux_str, "%d", contCondicion);
				push(stack_pos, aux_str);
			}
			  P_A condicion P_C { 
				sprintf(auxEtiquetas, "#fin_%s", top(stack_pos));
				enqueue(&qPolaca, auxEtiquetas);
			}
			L_A
			{
				sprintf(auxEtiquetas, "#bloq_%s:", top(stack_pos));
				enqueue(&qPolaca, auxEtiquetas);
			}

condicion:	comparacion 
			| comparacion		
			{ 
				sprintf(aux_str,"#fin_%s",top(stack_pos));
				enqueue(&qPolaca,aux_str);			
			}
			OP_AND comparacion	
			| comparacion 
			{
				invertirSalto(&qPolaca);
				sprintf(aux_str,"#jmp bloq_%s",top(stack_pos));
				enqueue(&qPolaca,aux_str);
			}
			OP_OR comparacion 	
			| OP_NOT comparacion  
			{ 
				invertirSalto(&qPolaca);
			}
			
comparacion:	expresion CMP_MAYOR expresion	{ enqueue(&qPolaca, "CMP"); enqueue(&qPolaca,"BLE"); }
			|	expresion CMP_MAYIG  expresion	{ enqueue(&qPolaca, "CMP"); enqueue(&qPolaca,"BLT"); }
			|	expresion CMP_DIST expresion	{ enqueue(&qPolaca, "CMP"); enqueue(&qPolaca,"BEQ"); }
			|	expresion CMP_IGUAL expresion	{ enqueue(&qPolaca, "CMP"); enqueue(&qPolaca,"BNE"); }
			|	expresion CMP_MENOR expresion	{ enqueue(&qPolaca, "CMP"); enqueue(&qPolaca,"BGE"); }
			|	expresion CMP_NENIG expresion	{ enqueue(&qPolaca, "CMP"); enqueue(&qPolaca,"BGT"); }
            |	f_inlist

expresion:		termino
		| expresion OP_SUM termino { enqueue(&qPolaca,"+"); auxOperaciones++; }
		| expresion OP_RES termino { enqueue(&qPolaca,"-"); auxOperaciones++; }

termino: 		factor 
		| termino OP_MUL  factor { enqueue(&qPolaca,"*"); auxOperaciones++; }
    	| termino OP_DIV  factor { enqueue(&qPolaca,"/"); auxOperaciones++; }


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

f_inlist: INLIST P_A ID 
			{
				enqueue(&qPolaca,$3);
				sprintf(aux_str, "_aux_%s", top(stack_pos));
				//insertar en tabla de simbolos a _aux_
				enqueue(&qPolaca,aux_str);
				auxOperaciones++;
				enqueue(&qPolaca,"=");
			} 
			PUNTO_Y_COMA C_A lista_expresion C_C P_C
			{
				enqueue(&qPolaca,"#jmp");
			}

lista_expresion:  expresion
			{
				if(esAsig && !is_queue_empty(&qVariablesAsig))
				{
					dequeue(&qVariablesAsig,aux_str);
					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,"=");
				}
				if(!esAsig)
				{
					sprintf(aux_str, "_aux_%s", top(stack_pos));
					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,"CMP");
					enqueue(&qPolaca,"BEQ");
					sprintf(aux_str,"bloq_%s", top(stack_pos));
					enqueue(&qPolaca,aux_str);
				}
			}
            | lista_expresion PUNTO_Y_COMA expresion
			{
				sprintf(aux_str, "_aux_%s", top(stack_pos));
				enqueue(&qPolaca,aux_str);
				enqueue(&qPolaca,"CMP");
				enqueue(&qPolaca,"BEQ");
				sprintf(aux_str,"bloq_%s", top(stack_pos));
				enqueue(&qPolaca,aux_str);
			}
            | lista_expresion COMA expresion
			{
				//Es por la asignacion multiple se tiene que ignorar en el caso que sobren expresiones
				//Ej [a,b]:=[1,2,2,2,2,2,2]
				if(esAsig && !is_queue_empty(&qVariablesAsig))
				{
					dequeue(&qVariablesAsig,aux_str);
					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,"=");
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
	generarASM(&qPolaca,auxOperaciones);
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

