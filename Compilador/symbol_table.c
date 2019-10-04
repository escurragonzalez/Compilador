#include <stdlib.h> /* malloc. */
#include <string.h> /* strlen. */
#include "symbol_table.h"

symrec *sym_table = (symrec *)0; 

symrec *putsym(const char *sym_name, int sym_type)
{
	symrec *ptr = (symrec *)malloc(sizeof(symrec));

	
	ptr->type = sym_type;
	
	if(ptr->type==tipoConstCadena)
	{
		ptr->name = (char *)malloc(strlen(sym_name) + 1);
		strcpy(ptr->name,normalizarSinComillas(sym_name));
	}
	else
	{
		ptr->name = (char *)malloc(strlen(sym_name) + 1);
		strcpy(ptr->name,normalizar(sym_name));
	}
	
	
	
	if(ptr->type==tipoConstCadena)
	{
		ptr->len = strlen(sym_name);
	}
	else
	{
		ptr->len = 0;
	}
	
	if(ptr->type!=sinTipo)
	{	
		ptr->valor = (char *)malloc(strlen(sym_name) + 1);
		strcpy(ptr->valor, sym_name);
	}
	else
	{
		ptr->valor = (char *)malloc((char) + 1);
		strcpy(ptr->valor, "");
	}
	
	ptr->next = (struct symrec *)sym_table;
	sym_table = ptr;

	return ptr;
}

symrec *getsym(char *sym_name)
{
	symrec *ptr;

	for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
		if (strcmp(ptr->name, normalizar(sym_name)) == 0)
			return ptr;

	return 0;
}



char* normalizarSinComillas(const char* cadena){
	char *aux = (char *) malloc( sizeof(char) * (strlen(cadena)) + 2);
	char *retor = (char *) malloc( sizeof(char) * (strlen(cadena)) + 2);
	
	strcpy(retor,cadena);
	int len = strlen(cadena);
	retor[len-1] = '\0';
	
	strcpy(aux,"_");
	strcat(aux,++retor);
	
	
	return aux;
}

char* normalizar(const char* cadena){
	char *aux = (char *) malloc( sizeof(char) * (strlen(cadena)) + 2);
	strcpy(aux,"_");
	strcat(aux,cadena);
	return aux;
}