defmodule FormatTest do
  use ExUnit.Case

  test "keyword list, provided format validation" do
    assert  Vex.valid?([component: "x1234"], component: [format: [with: %r(^x\d+$)]])
    assert !Vex.valid?([component: "d1234"], component: [format: [with: %r(^x\d+$)]])
  end

end
