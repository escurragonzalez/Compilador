#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

/* Data type for links in the chain of symbols.  */
struct symrec
{
	char *name; /* name of symbol */
	int type;   /* type of symbol */
	int len;	/* lenght of symbol */
	char *valor;
	struct symrec *next; /* link field */
};


typedef struct symrec symrec;

/* The symbol table: a chain of 'struct symrec'.  */
extern symrec *sym_table;

enum tipoDato
{
    tipoConstEntero,
    tipoConstReal,
    tipoConstCadena,
    sinTipo,
    tipoInt,
    tipoFloat,
    tipoString
};

symrec *putsym(char const *, int);
symrec *getsym(char *);
char* normalizar(const char*);

#endif /* SYMBOL_TABLE_H */