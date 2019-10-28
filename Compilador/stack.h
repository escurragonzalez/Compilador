#ifndef STACK_H
#define STACK_H
#include "tipodato.h"

struct m10_stack_entry {
  char *data;
	_tipoDato type;
  struct m10_stack_entry *next;
};

struct m10_stack_t
{
  struct m10_stack_entry *head;
  size_t stackSize; 
};

typedef struct m10_stack_t m10_stack_t;
extern m10_stack_t *st;
extern m10_stack_t *stIdType;

struct m10_stack_t *newStack(void);
char *copyString(char *);
void push(struct m10_stack_t *, char *value);
char *top(struct m10_stack_t *);
void pop(struct m10_stack_t *);
void clear (struct m10_stack_t *);
void destroyStack(struct m10_stack_t **);
void topSt(struct m10_stack_t *,m10_stack_t *);
void pushSt(struct m10_stack_t *, char *,_tipoDato );

#endif
