#include <stdlib.h>
#include <stdbool.h>

typedef struct Stack Stack;

Stack * stack_alloc(void);
void stack_free(Stack * const stack);

void stack_push(Stack * const stack, int const x);
int stack_pop(Stack * const stack);

void stack_set(Stack * const stack, size_t const ix, int const x);
int stack_get(Stack const * const stack, size_t const ix);

bool stack_is_empty(Stack const * const stack);
size_t stack_size(Stack const * const stack);
size_t stack_capacity(Stack const * const stack);
