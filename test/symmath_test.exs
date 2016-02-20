defmodule SymMathTest do
  use ExUnit.Case
  import SymMath

  test "simplify 0 + (1 + 0)" do
    assert Macro.to_string(simplify(quote do: 0 + (1 + 0))) == "1"
  end

  test "simplify 0 * :x" do
    assert Macro.to_string(simplify(quote do: 0 * :x)) == "0"
  end

  test "simplify 1 * (:x + 1)" do
    assert Macro.to_string(simplify(quote do: 1 * (:x + 1))) == ":x + 1"
  end

#  test "simplify :x + :x" do
#    assert Macro.to_string(simplify(quote do: :x + :x)) == "2 * :x"
#  end

  test "simplify 2 * (3 * :x)" do
    assert Macro.to_string(simplify(quote do: 2 * (3 * :x))) == "6 * :x"
  end

  test "simplify 1 * :x" do
    assert Macro.to_string(simplify(quote do: 1 * :x)) == ":x"
  end

  test "simplify -1 * :x" do
    assert Macro.to_string(simplify(quote do: -1 * :x)) == "-:x"
  end

  test "dif 1" do
    assert dif(1) == 0
  end

  test "dif x" do
    assert dif(:x) == 1
  end

  test "dif x + 1" do
    assert Macro.to_string(dif(:x + 1)) == "1 + 0"
  end

  test "dif :x + :x" do
    assert Macro.to_string(dif(:x + :x)) == "1 + 1"
  end

  test "dif :x * :x" do
    assert Macro.to_string(dif(:x * :x)) == "1 * :x + :x * 1"
  end

  test "dif sin(x)" do
    assert Macro.to_string(dif(sin(:x))) == "cos(:x)"
  end

  test "dif cos(x)" do
    assert Macro.to_string(dif(cos(:x))) == "-1 * sin(:x)"
  end

  test "dif sin(x) + cos(x)" do
    assert Macro.to_string(dif(sin(:x) + cos(:x))) == "cos(:x) + -1 * sin(:x)"
  end

  test "dif g(f(x)" do
    assert Macro.to_string(dif(g(f(:x)))) == "dif_g(f(:x)) * dif_f(:x)"
  end

  test "dif pow(sin(:x), 2)" do
    assert Macro.to_string(dif(pow(sin(:x), 2))) == "2 * sin(:x) * cos(:x)"
  end

  test "dif pow(sin(:x), 3)" do
    assert Macro.to_string(dif(pow(sin(:x), 3))) == "3 * pow(sin(:x), 2) * cos(:x)"
  end

end
