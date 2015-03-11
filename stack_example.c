#include <stdlib.h>
#include <stdio.h>
#include "realtime_dynamic_int_stack.h"

int main() {
  Stack * const stack = stack_alloc();

  printf("Stack capacity: %lu\n", stack_capacity(stack));
  
  for (int i = 1; i <= 1000; i++)
    stack_push(stack, i);

  printf("Stack capacity: %lu\n", stack_capacity(stack));
  stack_set(stack, 31, 33);
  
  int sum = 0;
  while (stack_size(stack) > 40)
    sum += stack_pop(stack);

  printf("Stack capacity: %lu\n", stack_capacity(stack));
  printf("%d\n", stack_get(stack, 31));

  while (stack_size(stack) > 0)
    sum += stack_pop(stack);

  printf("Stack capacity: %lu\n", stack_capacity(stack));
  printf("%d\n", sum);
  
  stack_free(stack);
  
  return 0;
}
