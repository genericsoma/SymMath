defmodule Mix.Tasks.Dif do
  use Mix.Task
  use SymMath

  @shortdoc "Differentiator"

  def run(_) do
    {:ok, expr} = Code.string_to_quoted IO.gets "Enter an expression: "
    q = quote do: simplify dif unquote expr
    {res, _} = Code.eval_quoted(q, [], __ENV__)
    IO.puts "Differentiated: " <> Macro.to_string res
  end

end

defmodule Mix.Tasks.Simplify do
  use Mix.Task
  use SymMath

  @shortdoc "Simplifier"

  def run(_) do
    {:ok, expr} = Code.string_to_quoted IO.gets "Enter an expression: "
    q = quote do: simplify unquote expr
    {res, _} = Code.eval_quoted(q, [], __ENV__)
    IO.puts "Simplified: " <> Macro.to_string res
  end

end