defmodule ByTest do
  use ExUnit.Case

  test "keyword list, provided function validation" do
    assert  Vex.valid?([component: "x1234"], component: &(&1 == "x1234"))
    assert !Vex.valid?([component: "x1234"], component: fn (c) -> c == "z1234" end)
    assert  Vex.valid?([component: "x1234"], component: fn (c) -> byte_size(c) > 4 end)
    assert  Vex.valid?([component: "x1234"], component: &(&1 != "BADCOMPONENT"))
    assert  Vex.valid?([component: "x1234"], component: [by: fn (x) -> x == "x1234" end])
  end

  test "keyword list, ok/error tuple return values" do
    x1234_match = fn("x1234") -> :ok; (_) -> {:error, :bad_param} end
    assert  Vex.valid?([component: "x1234"], component: x1234_match)
    assert !Vex.valid?([component: "z1234"], component: x1234_match)

    assert [{:error, :component, :by, :bad_param}] ==
      Vex.errors([component: "z1234"], component: x1234_match)
  end

end
