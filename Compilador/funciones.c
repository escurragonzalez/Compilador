#include "symbol_table.h"
#include "symbol_table.c"
#include <float.h>
#include <stdio.h>
#include <stdlib.h>

enum tipoDeError
{
    ErrorSintactico,
    ErrorLexico
};

enum tipoDato
{
    tipoEntero,
    tipoReal,
    tipoCadena,
    sinTipo
};

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
    errorCaracterInvalido
};

const CADENA_MAXIMA = 31;

void getAllSymbols(FILE* );
char* getDataTypeName(enum tipoDato tipo);
void insertarEnTablaDeSimbolos(enum tipoDato tipo,char *,int );

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
    }
    system ("Pause");
    exit (1);
}


void insertarEnTablaDeSimbolos(enum tipoDato tipo,char *valor,int linea)
{
    float aux;
    int auxint;
    switch (tipo) {
        case tipoReal:
            sscanf(valor, "%f", &aux);
            if (isValidFloat(aux) == 1)
            {
                symrec *s;
                s = getsym(valor);
                if (s == 0)
                {
                    putsym(valor,tipoReal);
                }
            }
            else
            {
                mensajeDeError(errorRealFueraDeRango,valor,linea);
            }
        break;
        case tipoCadena:
            if (strlen(valor) <= CADENA_MAXIMA)
            {
                symrec *s;
                s = getsym(valor);
                if (s == 0)
                {
                    putsym(valor,tipoEntero);
                }
            }
            else
            {
                mensajeDeError(errorCadenaDemasiadoLarga,valor,linea);
            }
        break;
        case tipoEntero:
            sscanf(valor,"%d",&auxint);
            if (isValidInt(auxint) == 1)
            {
                symrec *s;
                s = getsym(valor);
                if (s == 0)
                {
                    putsym(valor,tipoEntero);
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
    if(num >= FLT_MIN && num <= FLT_MAX )
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

    fprintf(pf,"\t%-30s\t|\t%-20s\t|\t%-32s\t|\t%-30s\n","Nombre","TipoDato","Valor","Longitud");
    fprintf(pf,"\t--------------------------------------------------------------------------------------------------------------------\n");

  	for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next)
    {
        fprintf(pf,"\t%-30s\t|\t%-20s\t|\t%-32s\t|\t%-30s\n",ptr->name,getDataTypeName(ptr->type),ptr->val,ptr->len);
    }
}

char* normalizar(char* cadena){
	char *aux = (char *) malloc( sizeof(char) * (strlen(cadena)) + 2);
	strcpy(aux,"_");
	strcat(aux,cadena);
	return aux;
}

char* getDataTypeName(enum tipoDato tipo){
    switch(tipo){
        case tipoReal:
            return("const_real");
            break;
        case tipoCadena:
            return("const_cadena");
            break;
        case tipoEntero:
            return("const_entera");
            break;
        case sinTipo:
            return("sin tipo");
            break;
    }
}