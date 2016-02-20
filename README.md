# SymMath

Symbolic differentiation using Elixir macros

`SymMath.dif` macro differentiates an expression with respect to `:x` atom, 
which singifies the independent variable.

There is `SymMath.simplify` macro which tries to perform some simplifications.

Finally, `SymMath.d_s` macro applies simplification after differentiation.

Only some standard functions and basic differention rules are coded. 
See the test script for some working examples.

Running `mix dif` calls d_s on the input.

## Examples

```
> mix dif
Enter an expression: pow(sin(:x), 2)
Differentiated: 2 * sin(:x) * cos(:x)

> mix dif
Enter an expression: pow(:x, 2) + 5 * :x
Differentiated: 2 * :x + 5
```
