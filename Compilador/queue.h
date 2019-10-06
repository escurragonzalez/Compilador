#ifndef QUEUE_H
#define QUEUE_H
#include <stdlib.h>

typedef struct s_node
{
	char * info;
	int pos;
	struct s_node *next;
} t_node;

typedef struct
{
	t_node *first;
	t_node *last;
	int counter;
} t_queue;

void init_queue(t_queue *);
void enqueue(t_queue *, char *);
void set_in_pos_in_queue(t_queue *, int, char *);
void dequeue(t_queue *, char *);
void top_queue(t_queue *, char *);
int is_queue_empty(t_queue *);
void print_queue(t_queue *);
void free_queue(t_queue *);

#endif