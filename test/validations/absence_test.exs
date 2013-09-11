defrecord AbsenceTestRecord, name: nil, identifier: nil do
  use Vex.Record

  validates :name, absence: true
end

defmodule AbsenceTest do
  use ExUnit.Case

  test "keyword list, provided absence validation" do
    assert !Vex.valid?([name: "Foo"], name:  [absence: true])
    assert  Vex.valid?([name: ""],    name:  [absence: true])
    assert !Vex.valid?([items: [:a]], items: [absence: true])
    assert  Vex.valid?([items: []],   items: [absence: true])
    assert  Vex.valid?([items: {}],   items: [absence: true])
    assert  Vex.valid?([name: "Foo"], id:    [absence: true])
  end

  test "keyword list, included absence validation" do
    assert !Vex.valid?([name: "Foo", _vex: [name: [absence: true]]])
    assert  Vex.valid?([name: "Foo", _vex: [id:   [absence: true]]])
  end

  test "record, included absence validation" do
    assert !Vex.valid?(AbsenceTestRecord.new name: "I have a name")
    assert  Vex.valid?(AbsenceTestRecord.new name: nil)
    assert  Vex.valid?(AbsenceTestRecord.new name: [])
    assert  Vex.valid?(AbsenceTestRecord.new name: "")
    assert  Vex.valid?(AbsenceTestRecord.new name: {})
  end

end
