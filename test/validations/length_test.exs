defmodule LengthTest do
  use ExUnit.Case

  test "keyword list, provided length validation with min and string" do
    assert  Vex.is_valid?([component: "x1234"], component: [length: [min: 1]])
    assert  Vex.is_valid?([component: "x1234"], component: [length: [min: 5]])
    assert !Vex.is_valid?([component: "x1234"], component: [length: [min: 6]])
  end

  test "keyword list, provided length validation with min and list" do
    assert  Vex.is_valid?([component: [1, 2, 3, 4, 5]], component: [length: [min: 1]])
    assert  Vex.is_valid?([component: [1, 2, 3, 4, 5]], component: [length: [min: 5]])
    assert !Vex.is_valid?([component: [1, 2, 3, 4, 5]], component: [length: [min: 6]])
  end

  test "keyword list, provided length validation with max and string" do
    assert  Vex.is_valid?([component: "x1234"], component: [length: [max: 10]])
    assert  Vex.is_valid?([component: "x1234"], component: [length: [max: 5]])
    assert !Vex.is_valid?([component: "x1234"], component: [length: [max: 1]])
  end

  test "keyword list, provided length validation with max and list" do
    assert  Vex.is_valid?([component: [1, 2, 3, 4, 5]], component: [length: [max: 10]])
    assert  Vex.is_valid?([component: [1, 2, 3, 4, 5]], component: [length: [max: 5]])
    assert !Vex.is_valid?([component: [1, 2, 3, 4, 5]], component: [length: [max: 1]])
  end

  test "keyword list, provided length validation with in as tuple" do
    assert  Vex.is_valid?([component: "x1234"], component: [length: [in: {0, 8}]])
    assert  Vex.is_valid?([component: "x1234"], component: [length: [in: {0, 5}]])
    assert !Vex.is_valid?([component: "x1234"], component: [length: [in: {0, 3}]])
  end

  test "keyword list, provided length validation with in as range" do
    assert  Vex.is_valid?([component: "x1234"], component: [length: [in: 0..8]])
    assert  Vex.is_valid?([component: "x1234"], component: [length: [in: 0..5]])
    assert !Vex.is_valid?([component: "x1234"], component: [length: [in: 0..3]])
  end

end
