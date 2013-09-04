defmodule VexTest do
  use ExUnit.Case

  test "keyword list, provided multiple validations" do
    assert Vex.is_valid?([name: "Foo"], name: [presence: true,
                                               length: [min: 2, max: 10],
                                               format: %r(^Fo.$)])
  end

  test "keyword list, provided presence validation" do
    assert  Vex.is_valid?([name: "Foo"], name: [presence: true])
    assert !Vex.is_valid?([name: "Foo"], id: [presence: true])
  end

  test "keyword list, included presence validation" do
    assert  Vex.is_valid?([name: "Foo", _vex: [name: [presence: true]]])
    assert !Vex.is_valid?([name: "Foo", _vex: [id: [presence: true]]])
  end

  test "keyword list, provided inclusion validation with a list without in keyword" do
    assert  Vex.is_valid?([category: :cows], category: [inclusion: [:cows, :pigs]])
    assert !Vex.is_valid?([category: :cats], category: [inclusion: [:cows, :pigs]])
  end

  test "keyword list, provided inclusion validation with a list" do
    assert  Vex.is_valid?([category: :cows], category: [inclusion: [in: [:cows, :pigs]]])
    assert !Vex.is_valid?([category: :cats], category: [inclusion: [in: [:cows, :pigs]]])
  end

  test "keyword list, provided exclusion validation with a list" do
    assert !Vex.is_valid?([category: :cows], category: [exclusion: [in: [:cows, :pigs]]])
    assert  Vex.is_valid?([category: :cats], category: [exclusion: [in: [:cows, :pigs]]])
  end

  test "keyword list, provided exclusion validation with a list without in keyword" do
    assert !Vex.is_valid?([category: :cows], category: [exclusion: [:cows, :pigs]])
    assert  Vex.is_valid?([category: :cats], category: [exclusion: [:cows, :pigs]])
  end

  test "keyword list, provided format validation" do
    assert  Vex.is_valid?([component: "x1234"], component: [format: [with: %r(^x\d+$)]])
    assert !Vex.is_valid?([component: "d1234"], component: [format: [with: %r(^x\d+$)]])
  end

  test "keyword list, provided confirmation validation" do
    assert  Vex.is_valid?([password: "1234",  password_confirmation: "1234"], [password: [confirmation: true]])
    assert !Vex.is_valid?([password: "1234"], password: [confirmation: true])
    assert !Vex.is_valid?([password: "1234",  password_confirmation: "1235"], [password: [confirmation: true]])
  end

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

  test "keyword list, provided function validation" do
    assert  Vex.is_valid?([component: "x1234"], component: &(&1 == "x1234"))
    assert !Vex.is_valid?([component: "x1234"], component: fn (c) -> c == "z1234" end)
    assert  Vex.is_valid?([component: "x1234"], component: fn (c) -> byte_size(c) > 4 end)
    assert  Vex.is_valid?([component: "x1234"], component: &(&1 != "BADCOMPONENT"))
    assert  Vex.is_valid?([component: "x1234"], component: [validated_by: fn (x) -> x == "x1234" end])
  end


end
