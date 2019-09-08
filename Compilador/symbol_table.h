#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

/* Data type for links in the chain of symbols.  */
struct symrec
{
	char *name; /* name of symbol */
	int type;   /* type of symbol */
	int len;	/* lenght of symbol */
	union {
		int intval;
		double val;
		char *str_val;
	};
	struct symrec *next; /* link field */
};

/*Data types*/
#define DT_CONST_FL 1
#define DT_ENTERO 2
#define DT_CONST_STR 3
#define DT_CONST_BOOL 4
#define DT_UNDEFINED 5
#define DT_FLOAT 6
#define DT_INT 7
#define DT_STRING 8
#define DT_BOOL 9


typedef struct symrec symrec;

/* The symbol table: a chain of 'struct symrec'.  */
extern symrec *sym_table;

symrec *putsym(char const *, int);
symrec *getsym(char const *);

#endif /* SYMBOL_TABLE_H */