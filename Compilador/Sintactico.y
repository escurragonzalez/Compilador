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
FILE *arch_reglas;
char *yyltext;
char *yytext;
char aux_str[30];
int esAsig=0;
int contCondicion=0;		//contador por polaca 
char auxEtiquetas[10];
int auxOperaciones=0;
_tipoDato tipoDatoVar = -1;
_tipoDato tipoDatoCompA;
_tipoDato tipoDatoCompB;

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

prorama:   bloq_decla bloque {fprintf(arch_reglas,"prorama:   bloq_decla bloque\n");}

bloq_decla: VAR declaraciones ENDVAR {fprintf(arch_reglas,"bloq_decla: VAR declaraciones ENDVAR\n");}

declaraciones:  declaracion {fprintf(arch_reglas,"declaraciones:  declaracion\n");}
			| declaraciones declaracion {fprintf(arch_reglas,"declaraciones: declaraciones declaracion\n");};

declaracion: C_A dec_multiple C_C {fprintf(arch_reglas,"declaracion: [ dec_multiple ] \n");}

dec_multiple: 	lista_tipo_dato C_C DOS_PUNTOS { esAsig=0; } C_A lista_id {fprintf(arch_reglas,"dec_multiple: 	lista_tipo_dato ] : [ lista_id\n");}

lista_tipo_dato: tipo_dato  {fprintf(arch_reglas,"lista_tipo_dato: tipo_dato\n");}
				| tipo_dato COMA lista_tipo_dato {fprintf(arch_reglas,"lista_tipo_dato: tipo_dato , lista_tipo_dato\n");}

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
					tipoDatoVar = obtenerTipoDatoId($1);
					enqueueType(&qVariablesAsig, $1,tipoDatoVar);		//Encolar en variables con tipo de datos, usado en Asig Multiple
				}
				fprintf(arch_reglas,"lista_id: ID\n");
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
					tipoDatoVar = obtenerTipoDatoId($3);
					enqueueType(&qVariablesAsig, $3,tipoDatoVar);

					tipoDatoVar = -1;
				}
				fprintf(arch_reglas,"lista_id: lista_id , ID\n");
			}

tipo_dato: 	REAL	{ enqueue(&qVariables,"float"); fprintf(arch_reglas,"tipo_dato: 	REAL\n");} 
			| STRING	{ enqueue(&qVariables,"string"); fprintf(arch_reglas,"tipo_dato: 	STRING\n");} 
			| INTEGER	{ enqueue(&qVariables,"int"); fprintf(arch_reglas,"tipo_dato: 	 INTEGER\n");} 

bloque: 	sentencia 		   {fprintf(arch_reglas,"bloque: 	sentencia\n");}
			| bloque sentencia {fprintf(arch_reglas,"bloque: 	bloque sentencia\n");}

sentencia:	ciclo {fprintf(arch_reglas,"sentencia:	ciclo \n");}
			| seleccion  {fprintf(arch_reglas,"sentencia:	seleccion\n");}
			| asignacion {fprintf(arch_reglas,"sentencia:	asignacion\n");}
			| intout {fprintf(arch_reglas,"sentencia:	intout\n");}							

intout: 	PRINT CONST_STR
			{
				enqueueType(&qPolaca, $2,tipoConstCadena);
				enqueue(&qPolaca, "PRINT");	
				fprintf(arch_reglas,"intout: PRINT  CONST_STR\n");
			}
	    	| READ  ID  
			{ 
				verificarExisteId($2,yylineno);
				enqueueType(&qPolaca, $2,obtenerTipoDatoId($2));
				enqueueType(&qPolaca, "READ",obtenerTipoDatoId($2));	
				fprintf(arch_reglas,"intout: READ  ID \n");
			}
			| PRINT  ID
			{
				verificarExisteId($2,yylineno);
				enqueueType(&qPolaca, $2,obtenerTipoDatoId($2));
				enqueueType(&qPolaca, "PRINT",obtenerTipoDatoId($2));	
				fprintf(arch_reglas,"intout: PRINT  ID \n");
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
			
			fprintf(arch_reglas,"ciclo:	REPEAT UNTIL ( condicion )\n");
		}
		
asignacion: 	ID OP_ASIG expresion 
				{
					verificarExisteId($1,yylineno);
					validarTipoDato(obtenerTipoDatoId($1),tipoDatoVar,yylineno);	// Valida si los tipos de datos son correctos

					enqueueType(&qPolaca, $1,tipoDatoVar);	// encolar en Polaca
					enqueue(&qPolaca, ":=");
					fprintf(arch_reglas,"asignacion: ID = expresion \n");

					tipoDatoVar = -1;
				}
				| asignacion_multiple {fprintf(arch_reglas,"asignacion: asignacion_multiple\n"); tipoDatoVar = -1;}

asignacion_multiple: C_A { esAsig=1; } lista_id C_C OP_ASIG C_A lista_expresion C_C { esAsig=0; fprintf(arch_reglas,"asignacion_multiple: [ lista_id ] = [ lista_expresion ]\n");}

seleccion:  condicion_if bloque L_C 
				{
					sprintf(aux_str,"#fin_%s:",top(stack_pos));
					enqueue(&qPolaca, aux_str);
					pop(stack_pos);
					fprintf(arch_reglas,"seleccion: condicion_if bloque } \n");
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
					fprintf(arch_reglas,"seleccion: condicion_if bloque }  ELSE { bloque }\n");
				}
                        
condicion_if: IF { 
				contCondicion++;
				sprintf(aux_str, "%d", contCondicion);
				push(stack_pos, aux_str);
			}
			  P_A condicion P_C { 
				sprintf(auxEtiquetas, "#fin_%s", top(stack_pos));
				enqueue(&qPolaca, auxEtiquetas);
				tipoDatoVar = -1;
			}
			L_A
			{
				sprintf(auxEtiquetas, "#bloq_%s:", top(stack_pos));
				enqueue(&qPolaca, auxEtiquetas);
				fprintf(arch_reglas,"condicion_if: IF ( condicion ) {\n");
			}

condicion:	comparacion {fprintf(arch_reglas,"condicion:	comparacion \n");}
			| comparacion		
			{ 
				sprintf(aux_str,"#fin_%s",top(stack_pos));
				enqueue(&qPolaca,aux_str);			
			}
			OP_AND comparacion	{fprintf(arch_reglas,"condicion: comparacion OP_AND comparacion \n");}
			| comparacion 
			{
				invertirSalto(&qPolaca);
				sprintf(aux_str,"#jmp bloq_%s",top(stack_pos));
				enqueue(&qPolaca,aux_str);
			}
			OP_OR comparacion {fprintf(arch_reglas,"condicion: comparacion OP_OR comparacion \n");}	
			| OP_NOT comparacion  
			{ 
				invertirSalto(&qPolaca);
				fprintf(arch_reglas,"condicion: OP_NOT comparacion\n");
			}
			
comparacion:	expresion {tipoDatoCompA=lastTypeQueue(&qPolaca);} CMP_MAYOR 
				expresion	
				{
					tipoDatoCompB=lastTypeQueue(&qPolaca); 
					
					if(tipoDatoCompB == sinTipo) {
						tipoDatoCompB = tipoDatoVar;
					}
					
					validarTipoDato(tipoDatoCompA,tipoDatoCompB,yylineno); 
					enqueue(&qPolaca, "CMP"); 
					enqueue(&qPolaca,"BLE"); 
					fprintf(arch_reglas,"comparacion: expresion > expresion\n");
				}
			|	expresion {tipoDatoCompA=lastTypeQueue(&qPolaca);} CMP_MAYIG  
				expresion	
				{
					tipoDatoCompB=lastTypeQueue(&qPolaca); 
					
					if(tipoDatoCompB == sinTipo) {
						tipoDatoCompB = tipoDatoVar;
					}
					
					validarTipoDato(tipoDatoCompA,tipoDatoCompB,yylineno); 
					enqueue(&qPolaca, "CMP"); 
					enqueue(&qPolaca,"BLT"); 
					fprintf(arch_reglas,"comparacion: expresion >=  expresion\n");
				}
			|	expresion {tipoDatoCompA=lastTypeQueue(&qPolaca);} CMP_DIST 
				expresion	
				{
					tipoDatoCompB=lastTypeQueue(&qPolaca); 
					
					if(tipoDatoCompB == sinTipo) {
						tipoDatoCompB = tipoDatoVar;
					}
					
					validarTipoDato(tipoDatoCompA,tipoDatoCompB,yylineno); 
					enqueue(&qPolaca, "CMP"); 
					enqueue(&qPolaca,"BEQ"); 
					fprintf(arch_reglas,"comparacion: expresion != expresion\n");
				}
			|	expresion {tipoDatoCompA=lastTypeQueue(&qPolaca);} CMP_IGUAL 
				expresion	{
					tipoDatoCompB=lastTypeQueue(&qPolaca); 
					
					if(tipoDatoCompB == sinTipo) {
						tipoDatoCompB = tipoDatoVar;
					}
					
					validarTipoDato(tipoDatoCompA,tipoDatoCompB,yylineno); 
					enqueue(&qPolaca, "CMP"); 
					enqueue(&qPolaca,"BNE"); 
					fprintf(arch_reglas,"comparacion: expresion == expresion\n");
				}
			|	expresion {tipoDatoCompA=lastTypeQueue(&qPolaca);} CMP_MENOR 
				expresion	
				{
					tipoDatoCompB=lastTypeQueue(&qPolaca); 
					
					if(tipoDatoCompB == sinTipo) {
						tipoDatoCompB = tipoDatoVar;
					}
					validarTipoDato(tipoDatoCompA,tipoDatoCompB,yylineno); 
					enqueue(&qPolaca, "CMP"); 
					enqueue(&qPolaca,"BGE"); 
					fprintf(arch_reglas,"comparacion: expresion < expresion\n");
				}
			|	expresion {tipoDatoCompA=lastTypeQueue(&qPolaca);} CMP_NENIG 
				expresion	
				{
					tipoDatoCompB=lastTypeQueue(&qPolaca);
					
					if(tipoDatoCompB == sinTipo) {
						tipoDatoCompB = tipoDatoVar;
					}
					
					validarTipoDato(tipoDatoCompA,tipoDatoCompB,yylineno); 
					enqueue(&qPolaca, "CMP"); 
					enqueue(&qPolaca,"BGT"); 
					fprintf(arch_reglas,"comparacion: expresion <= expresion\n");
				}
            |	f_inlist {fprintf(arch_reglas,"comparacion: f_inlist\n");}

expresion:		termino {fprintf(arch_reglas,"expresion: termino\n");}
		| expresion OP_SUM termino { enqueue(&qPolaca,"+"); auxOperaciones++; fprintf(arch_reglas,"expresion: expresion + termino\n");}
		| expresion OP_RES termino { enqueue(&qPolaca,"-"); auxOperaciones++; fprintf(arch_reglas,"expresion: expresion - termino\n");}

termino: 		factor  {fprintf(arch_reglas,"termino: factor\n");}
		| termino OP_MUL  factor { enqueue(&qPolaca,"*"); auxOperaciones++; fprintf(arch_reglas,"termino: termino *  factor\n");}
    	| termino OP_DIV  factor { enqueue(&qPolaca,"/"); auxOperaciones++; fprintf(arch_reglas,"termino: termino /  factor\n");}


factor:     ID 
			{ 
				verificarExisteId($1,yylineno);
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					if(tipoDatoVar == -1) {
						tipoDatoVar = obtenerTipoDatoId($1);
					} else {
						validarTipoDatoExpresion(tipoDatoVar, obtenerTipoDatoId($1), yylineno);
					}
					enqueueType(&qPolaca,$1,obtenerTipoDatoId($1));
				}
				fprintf(arch_reglas,"factor: ID\n");
			}
			| CONST_INT 
			{ 
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					if(tipoDatoVar == -1) {
						tipoDatoVar = tipoConstEntero;
					} else {
						validarTipoDatoExpresion(tipoDatoVar, tipoConstEntero, yylineno);
					}

					enqueueType(&qPolaca,$1,tipoConstEntero);
				}
				fprintf(arch_reglas,"factor: CONST_INT\n");
			}
			| CONST_REAL 
			{ 
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					if(tipoDatoVar == -1) {
						tipoDatoVar = tipoConstReal;
					} else {
						validarTipoDatoExpresion(tipoDatoVar, tipoConstReal, yylineno);
					}

					enqueueType(&qPolaca,$1,tipoConstReal);
				}
				fprintf(arch_reglas,"factor: CONST_REAL\n");
			}
			| CONST_STR 
			{
				if((!is_queue_empty(&qVariablesAsig) && esAsig) || !esAsig)
				{
					if(tipoDatoVar == -1) {
						tipoDatoVar = tipoConstCadena;
					} else {
						validarTipoDatoExpresion(tipoDatoVar, tipoConstCadena, yylineno);
					}
					
					enqueueType(&qPolaca,$1,tipoConstCadena);
				}	
				fprintf(arch_reglas,"factor: CONST_STR\n");
			}
			| P_A expresion P_C {fprintf(arch_reglas,"factor: ( expresion )\n");}

f_inlist: INLIST P_A ID 
			{
				enqueueType(&qPolaca,$3,obtenerTipoDatoId($3));
				sprintf(aux_str, "aux_%s", top(stack_pos));
				insertarEnTablaDeSimbolos(obtenerTipoDatoId($3),aux_str,yylineno);
				//asignarTipo(aux_str,descripcionTipo(obtenerTipoDatoId($3)),yylineno);
				enqueueType(&qPolaca,aux_str,obtenerTipoDatoId($3));
				auxOperaciones++;
				enqueue(&qPolaca,":=");
			} 
			PUNTO_Y_COMA C_A lista_expresion C_C P_C
			{
				enqueue(&qPolaca,"*jmp");
				fprintf(arch_reglas,"f_inlist: INLIST ( ID ; [ lista_expresion ] )\n");
			}

lista_expresion:  expresion
			{
				if(esAsig && !is_queue_empty(&qVariablesAsig))
				{
					tipoDatoCompA = firstTypeQueue(&qVariablesAsig);
					dequeue(&qVariablesAsig,aux_str);

					validarTipoDato(tipoDatoCompA, lastTypeQueue(&qPolaca), yylineno);

					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,":=");
				}
				if(!esAsig)
				{
					sprintf(aux_str, "aux_%s", top(stack_pos));
					enqueue(&qPolaca,aux_str);
					enqueue(&qPolaca,"CMP");
					enqueue(&qPolaca,"BEQ");
					sprintf(aux_str,"#bloq_%s", top(stack_pos));
					enqueue(&qPolaca,aux_str);
				}
				fprintf(arch_reglas,"lista_expresion:  expresion\n");
			}
            | lista_expresion PUNTO_Y_COMA expresion
			{
				sprintf(aux_str, "aux_%s", top(stack_pos));
				enqueue(&qPolaca,aux_str);
				enqueue(&qPolaca,"CMP");
				enqueue(&qPolaca,"BEQ");
				sprintf(aux_str,"#bloq_%s", top(stack_pos));
				enqueue(&qPolaca,aux_str);
				fprintf(arch_reglas,"lista_expresion:  lista_expresion ; expresion\n");
			}
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
				fprintf(arch_reglas,"lista_expresion:  lista_expresion , expresion\n");
			}

%%

int main(int argc,char *argv[])
{
	stVariables = newStack();
	stack_pos = newStack();	//inicia por polaca
	init_queue(&qVariables);
	init_queue(&qVariablesAsig);
	init_queue(&qPolaca);
 
	arch_reglas = fopen("reglas.txt","w"); 
	if (!arch_reglas)
        printf("\nNo se puede abrir el archivo reglas.txt \n");
	 
	
    if ((yyin = fopen(argv[1], "rt")) == NULL)
    {
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
    }
    else
    {
        yyparse();
    }
    fclose(yyin);
	fclose(arch_reglas);
	print_file_queue(&qPolaca);//Archivo intermedia.txt
	print_queue(&qPolaca);//Muestra polaca por consola
	generarASM(&qPolaca,auxOperaciones);
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

