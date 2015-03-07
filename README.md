# realtime_dynamic_int_stack
Dynamic random access int stack in C with guaranteed constant time operations.

Implementation of a stack for storing `int`s, that grows and shrinks dynamically.
All operations are guaranteed to occur in constant time (not just amortized constant time).
The space usage is linear in the number of elements, but with a constant factor of 3.5 compared to an array.

The code is compatible with the C99 standard and higher and the example can be compiled with

	clang -std=c11 -Weverything realtime_dynamic_int_stack.c example.c -o example
	./example

The stack stores `int` because that's all I need for my course, but it should be easy to store void pointers or anything else instead by modifying the code.
