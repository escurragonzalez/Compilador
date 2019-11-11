#include "symbol_table.h"
#include "symbol_table.c"
#include "queue.h"
#include "stack.h"
#include <float.h>
#include <stdio.h>
#include <stdlib.h>

//Tabla de simbolos
typedef struct
{
    char nombre[100];
    char valor[100];
    enum tipoDato tipo;
    int longitud;
} registro;

enum error
{
    errorEnteroFueraDeRango,
    errorRealFueraDeRango,
    errorCadenaDemasiadoLarga,
    errorIdDemasiadoLargo,
    errorCaracterInvalido,
    ErrorIdNoDeclarado,
    ErrorSintactico,
    ErrorLexico
};

const CADENA_MAXIMA = 31;

void getAllSymbols(FILE* );
const char* getDataTypeName(enum tipoDato tipo);
void insertarEnTablaDeSimbolos(enum tipoDato tipo,char *,int );
void verificarExisteId(char *,int);
enum tipoDato obtenerTipo(char *);
FILE * recorrerPolaca(FILE *,t_queue *);
char * prepararEtiqueta(char *);
symrec *buscarId(char *);
char * obtenerOperacion(char * ,_tipoDato);


void mensajeDeError(enum error error,const char* info, int linea)
{
	printf("[Linea %d] ",linea);
	switch(error){ 

        case errorEnteroFueraDeRango: 
            printf("ERROR LEXICO. Descripcion: Entero %s fuera de rango \n",info);
            break ;

		case errorRealFueraDeRango: 
            printf("ERROR LEXICO. Descripcion: Real %s fuera de rango. Debe ser un real de 32bits.\n",info);
            break ;

        case errorCadenaDemasiadoLarga:
            printf("ERROR LEXICO. Descripcion: Cadena \"%s\" fuera de rango. La longitud maxima es de 30 caracteres.\n", info);
            break ; 

        case errorIdDemasiadoLargo:
            printf("ERROR LEXICO. Descripcion: El id \"%s\" es demasiado largo. La longitud maxima es de 30 caracteres.\n", info);
            break ; 

        case errorCaracterInvalido:
        	printf("ERROR LEXICO. Descripcion: El caracter %s es invalido.\n",info);
        	break;
        case ErrorIdNoDeclarado:
		    printf("Descripcion: el id '%s' no ha sido declarado\n", info);
		    break;
        case ErrorSintactico:
            printf("Error de Sintaxis Descripcion: %s\n", info);
		    break;
        case ErrorLexico:
            printf("Error Léxico Descripcion: %s\n", info);
		    break;
    }
	
    system ("Pause");
    exit (1);
}


void insertarEnTablaDeSimbolos(enum tipoDato tipo,char *valor,int linea)
{
    float aux;
    int auxint;
    switch (tipo) {
        case tipoConstReal:
            sscanf(valor, "%.6f", &aux);
            if (isValidFloat(aux) == 1)
            {
                symrec *s;
                s = getsym(valor);
                if (s == 0)
                {
                    putsym(valor,tipoConstReal);
                }
            }
            else
            {
                mensajeDeError(errorRealFueraDeRango,valor,linea);
            }
        break;
        case tipoConstCadena:
            if (strlen(valor) <= CADENA_MAXIMA)
            {
                symrec *s;
                s = getsym(valor);
                if (s == 0)
                {
                    putsym(valor,tipoConstCadena);
                }
            }
            else
            {
                mensajeDeError(errorCadenaDemasiadoLarga,valor,linea);
            }
        break;
        case tipoConstEntero:
            sscanf(valor,"%d",&auxint);
            if (isValidInt(auxint) == 1)
            {
                symrec *s;
                s = getsym(valor);
                if (s == 0)
                {
                    putsym(valor,tipoConstEntero);
                }
            }
            else
            {
                mensajeDeError(errorEnteroFueraDeRango,valor,linea);
            }
        break;
        case sinTipo:            
        	if(strlen(valor)>=CADENA_MAXIMA)
               mensajeDeError(errorCadenaDemasiadoLarga, valor,linea);
            symrec *s;
            s = getsym(valor);
            if (s == 0)
            {
                putsym(valor,sinTipo);
            }
    }
}

int isValidFloat(double num)
{
    if(num >= DBL_MIN && num <= DBL_MAX )
    {
        return 1; 
	}
    return 0;
}

int isValidInt(int entero)
{
	if (entero >= -32768 && entero <= 32767)
    {
       return 1; 
	}
    return 0;
}

void createSymbolTable(int linea){
	FILE *pf; 
	pf = fopen("ts.txt","w"); 
	if (!pf)
		mensajeDeError(ErrorLexico,"Error al crear Tabla de simbolos",linea);
    getAllSymbols(pf);
	fclose(pf);
}

void getAllSymbols(FILE* pf) {
    symrec *ptr;
    char idName[CADENA_MAXIMA];

    fprintf(pf,"%-32s|\t%-20s\t|\t%-32s\t|\t%-30s\n","Nombre","TipoDato","Valor","Longitud");
    fprintf(pf,"--------------------------------------------------------------------------------------------------------------------\n");

  	for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next)
    {
        fprintf(pf,"%-32s|\t%-20s\t|\t%-32s\t|\t%-30d\n",ptr->name,getDataTypeName(ptr->type),ptr->valor,ptr->len);
    }
}

const char* getDataTypeName(enum tipoDato tipo){
    switch(tipo){
        case tipoConstReal:
            return("const_real");
            break;
        case tipoConstCadena:
            return("const_cadena");
            break;
        case tipoConstEntero:
            return("const_entera");
            break;
        case sinTipo:
            return("sin tipo");
            break;
        case tipoFloat:
            return("float");
            break;
        case tipoInt:         
            return("int");
            break;
        case tipoString:
            return("string");
            break;
    }
}

void verificarExisteId(char *s,int linea)
{
	if(buscarId(s)->type==sinTipo)
	{
        mensajeDeError(ErrorSintactico,"Variable no declarada",linea);
	}
}

symrec *buscarId(char *s)
{
	symrec *sym;
	sym = getsym(s);
    return sym;
}

_tipoDato obtenerTipoDatoId(char *id)
{
	symrec *sym;
	sym = getsym(id);
    return sym->type;
}

void asignarTipo(char *id,char * tipo,int linea)
{
    symrec *sym;
    sym = getsym(id);
    if(sym!=0)
    {
        if(sym->type==sinTipo)
        {
            sym->type = obtenerTipo(tipo);
        }
        else
        {
            mensajeDeError(ErrorSintactico,"Variable ya declarada anteriormente",linea);
        }
    }
}

enum tipoDato obtenerTipo(char *tipoDato)
{
    if(strcmp(tipoDato,"float")==0)
    {
        return tipoFloat;
    }else if(strcmp(tipoDato,"int")==0)
    {
        return tipoInt;
    }else if(strcmp(tipoDato,"string")==0)
    {
        return tipoString;
    }
    return sinTipo;
}

// Funcion para obtener comprarador de Assembler
char *invertirSalto(t_queue *comparador){
	if(strcmp(comparador->last->info,"BEQ")==0)
	{
		strcpy(comparador->last->info,"BNE");
	}
	else if(strcmp(comparador->last->info,"BNE")==0)
	{
		strcpy(comparador->last->info,"BEQ");
	}
	else if(strcmp(comparador->last->info,"BGT")==0)
	{
		strcpy(comparador->last->info,"BLT");
	}
	else if(strcmp(comparador->last->info,"BLT")==0)
	{
		strcpy(comparador->last->info,"BGT");
	}
	else if(strcmp(comparador->last->info,"BGE")==0)
	{
		strcpy(comparador->last->info,"BLE");
	}
	else if(strcmp(comparador->last->info,"BLE")==0)
	{
		strcpy(comparador->last->info,"BGE");
	}
}

int verificarCompatible(int a,int b)
{
	if(a==b)
		return 1;
	if(a==tipoConstEntero && b==tipoInt || b==tipoConstEntero && a==tipoInt )
		return 1;
	if(a==tipoConstReal && b==tipoFloat || b==tipoConstReal && a==tipoFloat )
		return 1;
	if(a==tipoConstCadena && b==tipoString || b==tipoConstCadena && a==tipoString )
		return 1;
	return 0;
}

char * tratarConstanteCadena(char * s)
{
    s=reemplazarCaracter(normalizarSinComillas(s));
	memmove(s,s+1,strlen(s));
    return s;
}

void generarASM(t_queue *p,int auxOperaciones)
{
    t_queue* aux_q=p;
    int i;
    char aux1[50]="aux\0";
    
    symrec *ptr;

    FILE* pf=fopen("final.asm","w+");
    if(!pf){
        printf("Error al guardar el archivo assembler.\n");
        exit(1);
    }
    //Cabecera
    fprintf(pf,"include macros2.asm\n");
    fprintf(pf,"include number.asm\n\n");
    fprintf(pf,".MODEL LARGE\n.STACK 200h\n.386\n.387\n.DATA\n\n\tMAXTEXTSIZE equ 50\n");
    //Variables y Constantes
    for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next)
    {
        fprintf(pf,"\t@%s ",ptr->name);
        switch(ptr->type){
            case tipoInt:
            case tipoFloat:
                fprintf(pf,"\tDD 0.0\n");
                break;
            case tipoString:
                fprintf(pf,"\tDB MAXTEXTSIZE dup (?),'$'\n");
                break;
            case tipoConstEntero:
                fprintf(pf,"\tDW %d\n",atoi(ptr->valor));
                break;
            case tipoConstReal:
			    fprintf(pf,"\tDD %s\n",ptr->valor);
                break;
            case tipoConstCadena:
	            memmove(ptr->valor,ptr->valor+1,strlen(ptr->valor));
                fprintf(pf,"\tDB \"%s\",'$',%d dup(?)\n",ptr->valor,50-ptr->len);
                break;   
        }
    }

    //Auxiliares que necesito
    for(i=0;i<auxOperaciones;i++)
	{
		fprintf(pf,"\t@_auxR%d \tDD 0.0\n",i);
		fprintf(pf,"\t@_auxE%d \tDW 0\n",i);
	}

    fprintf(pf,"\n.CODE\n.startup\n\tmov AX,@DATA\n\tmov DS,AX\n\n\tFINIT\n\n");
    pf=recorrerPolaca(pf,aux_q);

    fprintf(pf,"\n\tmov ah, 4ch\n\tint 21h\n");
    fprintf(pf,"\nend");
    fclose(pf);
}

FILE * recorrerPolaca(FILE *pfile,t_queue *p)
{
    FILE * f=pfile;
    t_queue *q=p;
    char aux1[50]="aux\0";
    char aux2[10];
    char * oper;
	int nroAuxE=0;
	int nroAuxR=0;
    t_node* nodo = malloc(sizeof(nodo));
    m10_stack_entry *d= malloc(sizeof(d));
    char * token;
    int td;
    m10_stack_t *stAsm= newStack();
    
    while(!is_queue_empty(q))
    {
        dequeueNode(q,nodo);

        //Variables y Constantes
        if(buscarId(nodo->info)!=NULL)
        {
            pushSt(stAsm,nodo->info,nodo->tipo);
        }
        if(nodo->tipo==tipoConstCadena)
        {   
            nodo->info=tratarConstanteCadena(nodo->info);
            if(buscarId(nodo->info)!=NULL)
            {
                pushSt(stAsm,nodo->info,nodo->tipo);
            }
        }

        if(strcmp(nodo->info,"*")==0 || strcmp(nodo->info,"+")==0 || strcmp(nodo->info,"/")==0 || strcmp(nodo->info,"-")==0 )
        {
            oper = copyString(nodo->info);
            topSt(stAsm,d);
            td=d->type;
            token = malloc(strlen(d->data)+1);
            token = copyString(d->data);
            pop(stAsm);
            topSt(stAsm,d);
            switch(d->type)
            {
                case tipoInt:
                case tipoConstEntero:
                    fprintf(f,"\tfild \t@%s\n",normalizar(token));
                    fprintf(f,"\t%s \t@%s\n",obtenerOperacion(oper,tipoInt),normalizar(d->data));
                    pop(stAsm);
                    strcpy(aux1,"auxE");
                    itoa(nroAuxE,aux2,10);
                    strcat(aux1,aux2);
                    fprintf(f,"\tfistp \t@_%s\n", aux1);
                    strcpy(nodo->info,aux1);
                    pushSt(stAsm,nodo->info,tipoInt);
                    nroAuxE++;
                break;
                case tipoFloat:
                case tipoConstReal:
                    fprintf(f,"\tfld \t@%s\n",normalizar(d->data));
                    fprintf(f,"\tfld \t@%s\n",normalizar(token));
                    pop(stAsm);
                    fprintf(f,"\t%s\n",obtenerOperacion(oper,tipoFloat));
                    strcpy(aux1,"auxR");
                    itoa(nroAuxR,aux2,10);
                    strcat(aux1,aux2);
                    fprintf(f,"\tfstp \t@_%s\n", aux1);
                    strcpy(nodo->info,aux1);
                    pushSt(stAsm,nodo->info,tipoFloat);
                    nroAuxR++;
                break;
            }
            free(token);
        }

        //Asignacion 
        if(strcmp(nodo->info,":=")==0)
        {
            topSt(stAsm,d);
            td=d->type;
            token = malloc(strlen(d->data)+1);
            token = copyString(d->data);
            pop(stAsm);
            topSt(stAsm,d);
                    
            switch(d->type)
            {
                case tipoInt:
                case tipoConstEntero:
                    fprintf(f,"\tfild \t@_%s\n",d->data);
                    fprintf(f,"\tfistp \t@_%s\n",token);
                    pop(stAsm);
                break;
                case tipoFloat:
                case tipoConstReal:
                    fprintf(f,"\tfld \t@%s\n",normalizar(d->data));
                    fprintf(f,"\tfstp \t@%s\n",normalizar(token));
                    pop(stAsm);
                break;
                case tipoConstCadena:
                case tipoString:
                    fprintf(f,"\tmov ax, @DATA\n\tmov ds, ax\n\tmov es, ax\n");
                    fprintf(f,"\tmov si, OFFSET\t@%s\n", d->data);
                    fprintf(f,"\tmov di, OFFSET\t@%s\n",token);
                    fprintf(f,"\tcall copiar\n");
                    pop(stAsm);
                break;
            }
            free(token);
        }

        if(strcmp(nodo->info,"CMP")==0)
        {
            topSt(stAsm,d);
            td=d->type;
            token = malloc(strlen(d->data)+1);
            token = copyString(d->data);
            pop(stAsm);
            topSt(stAsm,d);
            
            switch(d->type)
            {
                case tipoInt:
                case tipoConstEntero:
                    fprintf(f,"\tfild \t@%s\n",token);
                    pop(stAsm);
                    fprintf(f,"\tfild \t@%s\n",d->data);
                break;
                case tipoFloat:
                case tipoConstReal:
                    fprintf(f,"\tfld \t@%s\n",token);
                    pop(stAsm);
                    fprintf(f,"\tfild \t@%s\n",d->data);
                break;
            }
        }
            
        // >
        if(strcmp(nodo->info,"BLE")==0)
        {
            fprintf(f,"\tfcomp\n\tfstsw\tax\n\tfwait\n\tsahf\n\tjbe\t\t");
        }

        //<
        if(strcmp(nodo->info,"BGE")==0)
        {
            fprintf(f,"\tfcomp\n\tfstsw\tax\n\tfwait\n\tsahf\n\tjae\t\t");
        }

        //!=
        if(strcmp(nodo->info,"BEQ")==0)
        {
            fprintf(f,"\tfcomp\n\tfstsw\tax\n\tfwait\n\tsahf\n\tje\t\t");
        }

        //==
        if(strcmp(nodo->info,"BNE")==0)
        {
            fprintf(f,"\tfcomp\n\tfstsw\tax\n\tfwait\n\tsahf\n\tjne\t\t");
        }

        //>=
        if(strcmp(nodo->info,"BLT")==0)
        {
            fprintf(f,"\tfcomp\n\tfstsw\tax\n\tfwait\n\tsahf\n\tjb\t\t");
        }

        //<=
        if(strcmp(nodo->info,"BGT")==0)
        {
            fprintf(f,"\tfcomp\n\tfstsw\tax\n\tfwait\n\tsahf\n\tja\t\t");
        }

        //ETIQUETAS
        if(strchr(nodo->info, '#')!=NULL)
        {
            fprintf(f,"%s\n",prepararEtiqueta(nodo->info));
        }   

        //Print
        if(strcmp(nodo->info,"PRINT")==0)
        {
            topSt(stAsm,d);
            fprintf(f,"\tnewLine 1\n"); 
            switch(d->type)
            {
                case tipoConstReal:
                case tipoFloat:
                    fprintf(f,"\tDisplayFloat \t@_%s ,2\n",d->data);
                break;
                case tipoConstEntero:
                case tipoInt:
                    fprintf(f,"\tDisplayInteger \t@_%s\n",d->data);
                    break;
                case tipoConstCadena:
                case tipoString:
                    fprintf(f,"\tmov dx,OFFSET \t@_%s\n",d->data);
                    fprintf(f,"\tmov ah,9\n");
                    fprintf(f,"\tint 21h\n");
                    break;	
            }
            fprintf(f,"\tnewLine 1\n"); 
            pop(stAsm);
        }

        if(strcmp(nodo->info,"READ")==0)
        {  
            topSt(stAsm,d);
            switch(nodo->tipo)
            {
                case tipoFloat:
                    fprintf(f,"\tgetFloat \t@_%s\n",d->data);
                break;
                case tipoInt:
                    fprintf(f,"\tGetInteger \t@_%s\n",d->data);
                    break;
                case tipoString:
                    fprintf(f,"\tgetString \t@_%s\n",d->data);
                    break;	
            }
            pop(stAsm);
        }
    }
	destroyStack(&stAsm);
    free(nodo);
    free(d);
    return f;
}

char* prepararEtiqueta(char *etiq)
{ 
    //Remueve el primer caracter
    memmove(&etiq[0], &etiq[1], strlen(etiq));
    return etiq;
}

void validarTipoDato(_tipoDato td1, _tipoDato td2, int linea) {

    if(td1==tipoInt && td2!=tipoConstEntero && td2!=tipoInt)
    {
        mensajeDeError(ErrorSintactico,"Error en asignacion por tipo de datos Entero",linea);
    }

    if(td1==tipoFloat && td2!=tipoConstReal && td2!=tipoFloat)
    {
        mensajeDeError(ErrorSintactico,"Error en asignacion por tipo de datos Real",linea);
    }

    if(td1==tipoString && td2!=tipoConstCadena && td2!=tipoString)
    {
        mensajeDeError(ErrorSintactico,"Error en asignacion por tipo de datos String",linea);
    }
}

char * obtenerOperacion(char * op,_tipoDato  tipo)
{
    switch(tipo)
    {
        case tipoInt:
        case tipoConstEntero:
            if(strcmp(op,"*")==0)
                return "fimul";
                
            if(strcmp(op,"+")==0)
                return "fiadd";
                
            if(strcmp(op,"/")==0)
                return "fidivr";
                
            if(strcmp(op,"-")==0)
                return "fisubr";
        break;
        case tipoFloat:
        case tipoConstReal:
            if(strcmp(op,"*")==0)
                return "fmul";
                
            if(strcmp(op,"+")==0)
                return "fadd";
                
            if(strcmp(op,"/")==0)
                return "fdivr";
                
            if(strcmp(op,"-")==0)
                return "fsubr";

        break;
    }
}


void validarTipoDatoExpresion(_tipoDato td1, _tipoDato td2, int linea) {

    if(td1==tipoInt || td1==tipoConstEntero)
    {
        if(td2 != tipoInt && td2 != tipoConstEntero)
        {
            mensajeDeError(ErrorSintactico,"Error en asignacion por tipo de datos Entero",linea);
        }
    }

    if(td1==tipoFloat || td1==tipoConstReal)
    {
        if(td2 != tipoFloat && td2 != tipoConstReal)
        {
            mensajeDeError(ErrorSintactico,"Error en asignacion por tipo de datos Entero",linea);
        }
    }

    if(td1==tipoString || td1==tipoConstCadena)
    {
        if(td2 != tipoString && td2 != tipoConstCadena)
        {
            mensajeDeError(ErrorSintactico,"Error en asignacion por tipo de datos Entero",linea);
        }
    }
}