defmodule ValidatedByTest do
  use ExUnit.Case

  test "keyword list, provided function validation" do
    assert  Vex.is_valid?([component: "x1234"], component: &(&1 == "x1234"))
    assert !Vex.is_valid?([component: "x1234"], component: fn (c) -> c == "z1234" end)
    assert  Vex.is_valid?([component: "x1234"], component: fn (c) -> byte_size(c) > 4 end)
    assert  Vex.is_valid?([component: "x1234"], component: &(&1 != "BADCOMPONENT"))
    assert  Vex.is_valid?([component: "x1234"], component: [validated_by: fn (x) -> x == "x1234" end])
  end

end
