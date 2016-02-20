SymMath
=======

Symbolic differentiation using Elixir macros

Example:

> mix dif
Enter an expression: pow(sin(:x), 2)
Differentiated: 2 * sin(:x) * cos(:x)

> mix dif
Enter an expression: pow(:x, 2) + 5 * :x
Differentiated: 2 * :x + 5