#include <stdlib.h>

typedef struct Stack Stack;

Stack * stack_alloc(void);
void stack_free(Stack * const stack);

void stack_push(Stack * const stack, int const x);
int stack_pop(Stack * const stack);

void stack_set(Stack * const stack, size_t const ix, int const x);
int stack_get(const Stack * const stack, size_t const ix);

size_t stack_size(const Stack * const stack);
size_t stack_capacity(const Stack * const stack);
