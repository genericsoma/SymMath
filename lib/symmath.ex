defmodule SymMath do

  defmacro __using__(_opts) do
    quote do
      import SymMath
    end
  end

  defmacro formula(expr) do
  	Macro.escape(expr)
  end

  @doc """
  Expand expression removing parens
  """
  def expand_sums(expr) do
    Macro.postwalk expr, fn 
      {:+, ctx, [a, {:+, ctx2, [b, c]}]} -> {:+, ctx, [{:+, ctx2, [a, b]}, c]}
      e -> e
    end
  end

  def simplify(expr) do
    #IO.puts "simplify #{inspect(expr)}"
    Macro.postwalk expr, fn 
      {:+, _, [0, e]} -> e
      {:+, _, [e, 0]} -> e
      {:*, _, [0, _e]} -> 0
      {:*, _, [1, e]} -> e
      {:*, _, [e, 1]} -> e
      {:/, _, [0, _e]} -> 0
      {:/, _, [e, 1]} -> e
      {:-, _, [a]} when is_number(a) -> -a
      {:+, _, [a, b]} when is_number(a) and is_number(b) -> a + b
      {:-, _, [a, b]} when is_number(a) and is_number(b) -> a - b
      {:*, _, [a, b]} when is_number(a) and is_number(b) -> a * b
      {:-, _, [e, e]} -> 0
      # a+(-b) -> a-b
      {:+, ctx, [a, {:-, _, [b]}]} -> {:-, ctx, [a, b]}
      # 1*e -> e
      {:*, _, [1, e]} -> e
      # -1*e -> -e
      {:*, ctx, [-1, e]} -> {:-, ctx, [e]}
      # a * b * e, e * a * b, a * e * b
      {:*, ctx, [a, {:*, _, [b, e]}]} when is_number(a) and is_number(b) -> 
        {:*, ctx, [a * b, e]}
      {:*, ctx, [e, {:*, _, [a, b]}]} when is_number(a) and is_number(b) -> 
        {:*, ctx, [a * b, e]}
      {:*, ctx, [a, {:*, _, [e, b]}]} when is_number(a) and is_number(b) -> 
        {:*, ctx, [a * b, e]}
      expr -> expr
    end
  end

  defmacro is_constant(expr) do
    quote do
      is_number(unquote(expr)) or is_atom(unquote(expr)) and unquote(expr) != :x
    end
  end

  def canonize(expr) do
    Macro.postwalk expr, fn 
      # Replace a-x by -1*x+a
      {:-, ctx, [a, e]} when is_constant(a) and not is_constant(e) -> {:+, ctx, [{:*, ctx, [-1, e]}, a]}
      # Put constant before expression in *, -x by -1*x
      {:*, ctx, [e, a]} when is_constant(a) and not is_constant(e) -> {:*, ctx, [a, e]}
      {:-, ctx, [e]} when not is_constant(e) -> {:*, ctx, [-1, e]}
      {:pow, ctx, [e, 1]} -> e
      e -> e
    end
  end

  defmacro dif(expr) do
    #IO.puts "dif #{inspect(expr)}"
    # Bring to "canonical" form
    expr = canonize(expr)
    case expr do
      expr when is_constant(expr) -> 0
      expr when expr == :x -> 1
      # primitive functions
      {:sin, ctx, [:x]} -> Macro.escape {:cos, ctx, [:x]}
      {:cos, ctx, [:x]} -> Macro.escape {:*, ctx, [-1, {:sin, ctx, [:x]}]}
      {:exp, ctx, [:x]} -> Macro.escape {:exp, ctx, [:x]}
      # alternative form
      #{:exp, _, [:x]} -> Macro.escape quote do: exp(:x)
      {:pow, _, [e, 0]} -> 0
      {:pow, ctx, [:x, 2]} -> Macro.escape {:*, ctx, [2, :x]}
      {:pow, ctx, [:x, a]} when is_number(a) -> 
        Macro.escape {:*, ctx, [a, {:pow, ctx, [:x, a - 1]}]}
      {:pow, ctx, [e, 2]} -> 
        ee = Macro.escape(e)
        quote do
         de = dif(unquote e)
         e = unquote(ee)
         quote do: 2 * unquote(e) * unquote(de)
        end
      {:pow, ctx, [e, a]} when is_number(a) -> 
        ee = Macro.escape(e)
        a1 = a - 1
        quote do
         de = dif(unquote e)
         e = unquote(ee)
         a = unquote(a)
         a1 = unquote(a1)
         quote do: unquote(a) * pow(unquote(e), unquote(a1)) * unquote(de)
        end
      # unknown function
      {f, _, [:x]} when is_atom(f) ->
        df = String.to_atom("dif_" <> to_string(f)) 
        Macro.escape quote do: unquote(df)(:x)
      # (f+g)'=f'+g'
      {:+, _, [f, g]} -> 
      	quote do
       	  df = dif(unquote f)
      	  dg = dif(unquote g)
          quote do: unquote(df) + unquote(dg)
        end
      # (f*g)'=f'*g + f*g'
      {:*, _, [f, g]} ->
        ff = Macro.escape(f)
        gg = Macro.escape(g)
        quote do
          df = dif(unquote f)
          dg = dif(unquote g)
          ff = unquote(ff)
          gg = unquote(gg)
          quote do: unquote(df) * unquote(gg) + unquote(ff) * unquote(dg)
        end
      # (f/g)'=(f'*g - f*g')/(g*g)
      {:/, _, [f, g]} ->
        ff = Macro.escape(f)
        gg = Macro.escape(g)
        quote do
          df = dif(unquote f)
          dg = dif(unquote g)
          ff = unquote(ff)
          gg = unquote(gg)
          quote do: (unquote(df) * unquote(gg) + unquote(ff) * unquote(dg)) / 
                    (unquote(gg) * unquote(gg))
        end
      # (f.g)'
      {g, _, [f]} when is_atom(g) ->
        #IO.puts ". #{inspect(g)} #{inspect(f)}"
        f_x = Macro.escape(f)
        quote do
          g = unquote(g)
          dg = dif(unquote(g)(:x))
          f_x = unquote(f_x)
          dg_f = put_elem(dg, 2, [unquote f_x])
          df = dif(unquote f)
          quote do: unquote(dg_f) * unquote(df)
        end
    end
  end

  defmacro d(expr) do
    quote do
      simplify dif unquote expr
    end
  end

end
