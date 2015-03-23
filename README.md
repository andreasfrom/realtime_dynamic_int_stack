# realtime_dynamic_int_stack
Dynamic random access int stack in C with guaranteed constant time operations.

Implementation of a stack for storing `int`s, that grows and shrinks dynamically.
All operations are guaranteed to occur in constant time (not just amortized constant time).
The space usage is linear in the number of elements, but with a constant factor of 3.5 compared to an array.

The code is compatible with the C99 standard and higher and the example can be compiled with

	clang -std=c11 -Weverything realtime_dynamic_int_stack.c stack_example.c -o stack_example
	./stack_example

The stack stores `int` because that's all I need for my course, but it should be easy to store void pointers or anything else instead by modifying the code.

# Testing
I'm using QuickCheck in Haskell to test the C code through the FFI.

The bindings are defined in `CStack.hs` and the properties in `Main.hs`.
