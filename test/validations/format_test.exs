defmodule FormatTest do
  use ExUnit.Case

  test "keyword list, provided format validation" do
    assert  Vex.is_valid?([component: "x1234"], component: [format: [with: %r(^x\d+$)]])
    assert !Vex.is_valid?([component: "d1234"], component: [format: [with: %r(^x\d+$)]])
  end

end
