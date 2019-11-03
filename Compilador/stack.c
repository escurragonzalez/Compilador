#include <stdlib.h>
#include <string.h>
#include "stack.h"

struct m10_stack_t *newStack(void)
{
  struct m10_stack_t *stack = malloc(sizeof *stack);
  if (stack)
  {
    stack->head = NULL;
    stack->stackSize = 0;
  }
  return stack;
}

char *copyString(char *str)
{
  char *tmp = malloc(strlen(str) + 1);
  if (tmp)
    strcpy(tmp, str);
  return tmp;
}

void push(struct m10_stack_t *theStack, char *value)
{
  struct m10_stack_entry *entry = malloc(sizeof *entry); 
  if (entry)
  {
    entry->data = copyString(value);
    entry->next = theStack->head;
    theStack->head = entry;
    theStack->stackSize++;
  }
}

void pushSt(struct m10_stack_t *theStack, char *value,_tipoDato t)
{
  struct m10_stack_entry *entry = malloc(sizeof *entry); 
  if (entry)
  {
    entry->data = copyString(value);
    entry->next = theStack->head;
    entry->type = t;
    theStack->head = entry;
    theStack->stackSize++;
  }
}

char *top(struct m10_stack_t *theStack)
{
  if (theStack && theStack->head)
    return theStack->head->data;
  else
    return NULL;
}

void topSt(struct m10_stack_t *theStack,m10_stack_entry *d)
{
  if (theStack && theStack->head)
  {
    d->data=copyString(theStack->head->data);
    d->type=theStack->head->type;
  }
}

void pop(struct m10_stack_t *theStack)
{
  if (theStack->head != NULL)
  {
    struct m10_stack_entry *tmp = theStack->head;
    theStack->head = theStack->head->next;
    free(tmp->data);
    free(tmp);
    theStack->stackSize--;
  }
}

void clear (struct m10_stack_t *theStack)
{
  while (theStack->head != NULL)
    pop(theStack);
}

void destroyStack(struct m10_stack_t **theStack)
{
  clear(*theStack);
  free(*theStack);
  *theStack = NULL;
}