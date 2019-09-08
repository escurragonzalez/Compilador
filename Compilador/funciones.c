#include "symbol_table.h"
#include "symbol_table.c"

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

enum valorMaximo
{
    ENTERO_MAXIMO = 65535,//sin signo
    CADENA_MAXIMA = 31,
};


void mensajeDeError(enum error error,const char* info, int linea)
{
	printf("[Linea %d] ",linea);
	switch(error){ 

        case errorEnteroFueraDeRango: 
            printf("ERROR LEXICO. Descripcion: Entero %s fuera de rango [0 ; %d]\n",info,ENTERO_MAXIMO);
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
