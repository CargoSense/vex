defrecord AbsenceTestRecord, name: nil, identifier: nil do
  use Vex.Record

  validates :name, absence: true
end

defmodule AbsenceTest do
  use ExUnit.Case

  test "keyword list, provided absence validation" do
    assert !Vex.is_valid?([name: "Foo"], name:  [absence: true])
    assert  Vex.is_valid?([name: ""],    name:  [absence: true])
    assert !Vex.is_valid?([items: [:a]], items: [absence: true])
    assert  Vex.is_valid?([items: []],   items: [absence: true])
    assert  Vex.is_valid?([items: {}],   items: [absence: true])
    assert  Vex.is_valid?([name: "Foo"], id:    [absence: true])
  end

  test "keyword list, included absence validation" do
    assert !Vex.is_valid?([name: "Foo", _vex: [name: [absence: true]]])
    assert  Vex.is_valid?([name: "Foo", _vex: [id:   [absence: true]]])
  end

  test "record, included absence validation" do
    assert !Vex.is_valid?(AbsenceTestRecord.new name: "I have a name")
    assert  Vex.is_valid?(AbsenceTestRecord.new name: nil)
    assert  Vex.is_valid?(AbsenceTestRecord.new name: [])
    assert  Vex.is_valid?(AbsenceTestRecord.new name: "")
    assert  Vex.is_valid?(AbsenceTestRecord.new name: {})
  end

end
