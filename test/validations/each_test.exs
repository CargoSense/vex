defmodule EachTest do
  use ExUnit.Case

  test "keyword list, each validation" do
    assert  Vex.valid?([tags: ["a", "b"]], tags: [each: &is_binary/1])
    assert !Vex.valid?([tags: [1, "b"]], tags: [each: &is_binary/1])
  end

  test "keyword list, each validation using a different validator" do
    assert Vex.valid?([animals: [:cows, :pigs]], animals: [each: [inclusion: [:cows, :pigs]]])
    assert !Vex.valid?([animals: [:sheep, :pigs]], animals: [each: [inclusion: [:cows, :pigs]]])
  end

end
