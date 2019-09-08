#include <stdlib.h>
#include <string.h>


struct m10_stack_entry {
  char *data;
  struct m10_stack_entry *next;
};

struct m10_stack_t
{
  struct m10_stack_entry *head;
  size_t stackSize; 
};

struct m10_stack_t *newStack(void)
{
  struct m10_stack_t *stack = malloc(sizeof *stack);
  if (stack)
  {
    stack->head = NULL;
    stack->stackSize = 0;
  }
  return stack;
};

char *copyString(char *);
void push(struct m10_stack_t *, char *value);
char *top(struct m10_stack_t *);
void pop(struct m10_stack_t *);
void clear (struct m10_stack_t *);
void destroyStack(struct m10_stack_t **);

typedef struct m10_stack_t m10_stack_t;
extern m10_stack_t *st;
extern m10_stack_t *stIdType;

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
  else
  {
    // handle error here
  }
}

char *top(struct m10_stack_t *theStack)
{
  if (theStack && theStack->head)
    return theStack->head->data;
  else
    return NULL;
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