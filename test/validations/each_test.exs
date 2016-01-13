defmodule EachTest do
  use ExUnit.Case

  test "each validator, against a list" do
    assert :ok == Vex.Validators.Each.validate([1, 2], &is_integer/1)
    assert {:error, ["must be valid"]} ==
      Vex.Validators.Each.validate([1, "b"], &is_integer/1)
  end

  test "each validator, against non-enumerable" do
    assert {:error, :not_enumerable} ==
      Vex.Validators.Each.validate(1, &is_integer/1)
  end

  test "each validator, against a dict" do
    valid? = fn ({k, v}) -> is_atom(k) and is_integer(v) end
    assert :ok == Vex.Validators.Each.validate(%{a: 1, b: 2}, valid?)
    assert {:error, ["must be valid"]} ==
      Vex.Validators.Each.validate(%{a: 1, b: :c}, valid?)
  end
end
