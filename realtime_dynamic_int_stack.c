#include <stdlib.h>
#include <assert.h>
#include "realtime_dynamic_int_stack.h"

static const int INITIAL_CAPACITY = 16;

struct Stack {
  int * primary;
  size_t size;
  size_t capacity;
  int * smaller;
  int * larger;
  size_t next_smaller;
  size_t next_larger;
};

Stack * stack_alloc() {
  int * smaller = malloc(INITIAL_CAPACITY / 2 * sizeof *smaller);
  assert(smaller);
  int * primary = malloc(INITIAL_CAPACITY * sizeof *primary);
  assert(primary);
  int * larger = malloc(INITIAL_CAPACITY * 2 * sizeof *larger);
  assert(larger);

  Stack * stack = malloc(sizeof *stack);
  assert(stack);

  *stack = (Stack) {
    .smaller = smaller, .primary = primary, .larger = larger,
    .size = 0, .capacity = INITIAL_CAPACITY,
    .next_larger = 0, .next_smaller = 0
  };

  return stack;
}

void stack_free(Stack * const stack) {
  assert(stack);
  free(stack->smaller);
  free(stack->primary);
  free(stack->larger);
  free(stack);
}

void stack_push(Stack * const stack, int const x) {
  assert(stack);

  if (stack->size >= stack->capacity) {
    stack->capacity *= 2;
    int * new_larger = malloc(2 * stack->capacity * sizeof *new_larger);
    assert(new_larger);
    free(stack->smaller);
    stack->smaller = stack->primary;
    stack->primary = stack->larger;
    stack->larger = new_larger;
    stack->next_larger = 0;
  }

  if (stack->next_larger < stack->capacity) {
    stack->larger[stack->next_larger] = stack->primary[stack->next_larger];
    stack->next_larger++;
  }

  stack->primary[stack->size] = x;
  stack->larger[stack->size] = x;
  stack->size++;
}

int stack_pop(Stack * const stack) {
  assert(stack);
  assert(stack->size > 0);

  if (stack->size <= stack->capacity/4 && stack->size > INITIAL_CAPACITY) {
    stack->capacity /= 2;
    int * new_smaller = malloc(stack->capacity / 2 * sizeof *new_smaller);
    assert(new_smaller);
    free(stack->larger);
    stack->larger = stack->primary;
    stack->primary = stack->smaller;
    stack->smaller = new_smaller;
    stack->next_smaller = 0;
  }

  if (stack->next_smaller < stack->capacity / 2) {
    stack->smaller[stack->next_smaller] = stack->primary[stack->next_smaller];
    stack->next_smaller++;
  }

  stack->size--;
  return stack->primary[stack->size];
}

void stack_set(Stack * const stack, size_t const ix, int const x) {
  assert(stack);
  assert(ix < stack->size);

  if (ix < stack->capacity / 2)
    stack->smaller[ix] = x;
  
  stack->primary[ix] = x;
  stack->larger[ix] = x;
}

int stack_get(const Stack * const stack, size_t const ix) {
  assert(stack);
  assert(ix < stack->size);
  return stack->primary[ix];
}

size_t stack_size(const Stack * const stack) {
  assert(stack);
  return stack->size;
}

size_t stack_capacity(const Stack * const stack) {
  assert(stack);
  return stack->capacity;
}
