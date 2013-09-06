defmodule PresenceTest do
  use ExUnit.Case

  test "keyword list, provided presence validation" do
    assert  Vex.is_valid?([name: "Foo"], name:  [presence: true])
    assert !Vex.is_valid?([name: ""],    name:  [presence: true])
    assert  Vex.is_valid?([items: [:a]], items: [presence: true])
    assert !Vex.is_valid?([items: []],   items: [presence: true])
    assert !Vex.is_valid?([items: {}],   items: [presence: true])
    assert !Vex.is_valid?([name: "Foo"], id:    [presence: true])
  end

  test "keyword list, included presence validation" do
    assert  Vex.is_valid?([name: "Foo", _vex: [name: [presence: true]]])
    assert !Vex.is_valid?([name: "Foo", _vex: [id: [presence: true]]])
  end

  test "record, included presence validation" do
    assert Vex.is_valid?(RecordTest.new name: "I have a name")
  end

end
