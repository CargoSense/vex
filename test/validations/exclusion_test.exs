defmodule ExclusionTest do
  use ExUnit.Case

  test "keyword list, provided exclusion validation with a list" do
    assert !Vex.is_valid?([category: :cows], category: [exclusion: [in: [:cows, :pigs]]])
    assert  Vex.is_valid?([category: :cats], category: [exclusion: [in: [:cows, :pigs]]])
  end

  test "keyword list, provided exclusion validation with a list without in keyword" do
    assert !Vex.is_valid?([category: :cows], category: [exclusion: [:cows, :pigs]])
    assert  Vex.is_valid?([category: :cats], category: [exclusion: [:cows, :pigs]])
  end

end
