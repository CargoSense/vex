defmodule ExclusionTest do
  use ExUnit.Case

  test "keyword list, provided exclusion validation with a list" do
    assert !Vex.valid?([category: :cows], category: [exclusion: [in: [:cows, :pigs]]])
    assert  Vex.valid?([category: :cats], category: [exclusion: [in: [:cows, :pigs]]])
  end

  test "keyword list, provided exclusion validation with a list without in keyword" do
    assert !Vex.valid?([category: :cows], category: [exclusion: [:cows, :pigs]])
    assert  Vex.valid?([category: :cats], category: [exclusion: [:cows, :pigs]])
  end

  test "map, provided exclusion validation with a list" do
    assert !Vex.valid?(%{"category" => :cows}, %{"category" => [exclusion: [in: [:cows, :pigs]]]})
    assert  Vex.valid?(%{"category" => :cats}, %{"category" => [exclusion: [in: [:cows, :pigs]]]})
  end

  test "map, provided exclusion validation with a list without in keyword" do
    assert !Vex.valid?(%{"category" => :cows}, %{"category" => [exclusion: [:cows, :pigs]]})
    assert  Vex.valid?(%{"category" => :cats}, %{"category" => [exclusion: [:cows, :pigs]]})
  end

end
