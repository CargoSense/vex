defmodule FormatTest do
  use ExUnit.Case

  test "keyword list, provided format validation" do
    assert  Vex.valid?([component: "x1234"], component: [format: [with: ~r/(^x\d+$)/]])
    assert !Vex.valid?([component: "d1234"], component: [format: [with: ~r/(^x\d+$)/]])
    assert !Vex.valid?([component: nil], component: [format: [with: ~r/(^x\d+$)/]])
  end

  test "custom error messages" do
    assert Vex.errors([component: "will not match"],
                      [component: [format: [with: ~r/foo/, message: "Custom!"]]])
            == [{:error, :component, :format, "Custom!"}]
    assert Vex.errors([component: "will not match"],
                      [component: [format: [with: ~r/foo/, message: "'<%= value %>' doesn't match <%= inspect pattern %>"]]])
            == [{:error, :component, :format, "'will not match' doesn't match ~r/foo/"}]
  end

end
