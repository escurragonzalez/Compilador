#include "symbol_table.h"
#include "symbol_table.c"
#include "queue.h"
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

enum tipoSalto{
	normal,
	inverso
};

enum tipoCondicion{
	condicionIf,
	condicionWhile
};

const CADENA_MAXIMA = 31;

void getAllSymbols(FILE* );
const char* getDataTypeName(enum tipoDato tipo);
void insertarEnTablaDeSimbolos(enum tipoDato tipo,char *,int );
void verificarExisteId(char *,int);
enum tipoDato obtenerTipo(char *);

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
	symrec *sym;
	sym = getsym(s);
	if(sym->type==sinTipo)
	{
        mensajeDeError(ErrorSintactico,"Variable no declarada",linea);
	}
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
char *obtenerSalto(char *comparador){
	if(strcmp(comparador,"==")==0)
		return("BEQ");
	if(strcmp(comparador,">")==0)
		return("BGT");
	if(strcmp(comparador,"<")==0)
		return("BLT");
	if(strcmp(comparador,">=")==0)
		return("BGE");
	if(strcmp(comparador,"<=")==0)
		return("BLE");
	if(strcmp(comparador,"!=")==0)
		return("BNE");

}

void generarASM(t_queue *p)
{
    t_queue* aux=p;
    int i;
    int nroAuxReal=0;
    int nroAuxEntero=0;
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
            case tipoConstReal:
                fprintf(pf,"\tDD %s\n",ptr->valor);
                break;
            case tipoConstCadena:
                fprintf(pf,"\tDB \"%s\",'$',%d dup(?)\n",ptr->valor,50-ptr->len);
                break;   
        }
    }

    fprintf(pf,"\n.CODE\n.startup\n\tmov AX,@DATA\n\tmov DS,AX\n\n\tFINIT\n\n");
    fprintf(pf,"\tmov ah, 4ch\n\tint 21h\n");
    fprintf(pf,"\nend");
    fclose(pf);
}
