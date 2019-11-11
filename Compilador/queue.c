#include "queue.h"

void init_queue(t_queue *p)
{
	p->first = p->last = NULL;
	p->counter = 0;
}

void enqueue(t_queue *p, char *d)
{
	t_node *n = (t_node *) malloc(sizeof(t_node));
	n->info = (char *) malloc(sizeof(char) * 30);
	n->tipo = sinTipo;
	if (n == NULL)
		exit(-1);

	strcpy(n->info, d);
	n->next = NULL;
	
	if (p->first == NULL)
		p->first = n;
	else
		p->last->next = n;
	
	p->last = n;

	n->pos = p->counter++;
}

void enqueueType(t_queue *p, char *d, _tipoDato tipo)
{
	enqueue(p,d);
	p->last->tipo=tipo;
}

void dequeue(t_queue *p, char *d)
{
	t_node *aux = p->first;
	strcpy(d, aux->info);
	p->first = aux->next;
	
	if (p->first == NULL)
		p->last = NULL;

	free(aux);

	p->counter--;
}

void dequeueNode(t_queue *p,t_node *d)
{
	d->info = (char *) malloc(sizeof(char) * 30);
	t_node *aux = p->first;
	strcpy(d->info, aux->info);
	d->tipo=aux->tipo;
	p->first = aux->next;
	
	if (p->first == NULL)
		p->last = NULL;

	free(aux);

	p->counter--;
}

void set_in_pos_in_queue(t_queue *p, int pos, char *d)
{
	int i;
	if (is_queue_empty(p))
		return;

	if (pos > p->counter)
		return;

	t_node *aux = p->first;

	for (i = 0; i < pos; i++)
		aux = aux->next;

	strcpy(aux->info, d);
}

void top_queue(t_queue *p, char *d)
{
	strcpy(d, p->first->info);
}

int is_queue_empty(t_queue *p)
{
	return p->first == NULL;
}

void print_queue(t_queue *p)
{
	t_node *aux;

	if (is_queue_empty(p))
		return;

	aux = p->first;

	while(aux)
	{
		printf("%s\n", aux->info);
		aux = aux->next;
	}
}

void free_queue(t_queue *p)
{
	t_node *aux;

	while(p->first)
	{
		aux = p->first;
		p->first = aux->next;
		free(aux->info);
		free(aux);
	}

	p->last = NULL;
	p->counter = 0;
}

void print_file_queue(t_queue *p)
{
	FILE *pf; 
	pf = fopen("intermedia.txt","w"); 

	t_node *aux;

	if (is_queue_empty(p))
		return;

	aux = p->first;

	while(aux)
	{
		fprintf(pf,"%s\n",aux->info);

		aux = aux->next;
	}
	
	fclose(pf); 
}

//funcion para devolver tipo de dato de cola de la ultima posicion
_tipoDato lastTypeQueue(t_queue *p) {
	return p->last->tipo;
}

//funcion para devolver tipo de dato de cola de la primera posicion
_tipoDato firstTypeQueue(t_queue *p) {
	return p->first->tipo;
}