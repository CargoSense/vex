defmodule InclusionTest do
  use ExUnit.Case

  test "keyword list, provided inclusion validation with a list without in keyword" do
    assert Vex.valid?([category: :cows], category: [inclusion: [:cows, :pigs]])
    assert !Vex.valid?([category: :cats], category: [inclusion: [:cows, :pigs]])
  end

  test "keyword list, provided inclusion validation with a list" do
    assert Vex.valid?([category: :cows], category: [inclusion: [in: [:cows, :pigs]]])
    assert !Vex.valid?([category: :cats], category: [inclusion: [in: [:cows, :pigs]]])
  end
end
