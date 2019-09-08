#include <stdlib.h> /* malloc. */
#include <string.h> /* strlen. */
#include "symbol_table.h"

symrec *sym_table = (symrec *)0; 

symrec *putsym(const char *sym_name, int sym_type)
{
	symrec *ptr = (symrec *)malloc(sizeof(symrec));

	ptr->name = (char *)malloc(strlen(sym_name) + 1);
	strcpy(ptr->name, sym_name);
	ptr->type = sym_type;
	ptr->len = strlen(sym_name);
	ptr->val = 0; /* Set value to 0 even if fctn.  */
	ptr->next = (struct symrec *)sym_table;
	sym_table = ptr;

	return ptr;
}

symrec *getsym(const char *sym_name)
{
	symrec *ptr;

	for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec *)ptr->next)
		if (strcmp(ptr->name, sym_name) == 0)
			return ptr;

	return 0;
}