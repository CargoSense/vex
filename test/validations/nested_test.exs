defmodule NestedTestRecord do
  defstruct author: nil
  use Vex.Struct

  validates [:author, :name], presence: true
end

defmodule NestedTest do
  use ExUnit.Case

  test "nested" do
    assert Vex.valid?([author: [name: "Foo"]], %{[:author, :name]  => [presence: true]})

    nested_errors = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors == Vex.errors([author: [name: ""]], %{[:author, :name]  => [presence: true]})
  end

  test "nested in Record" do
    assert Vex.valid?(%NestedTestRecord{author: [name: "Foo"]})

    nested_errors = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors == Vex.errors(%NestedTestRecord{author: [name: ""]})
  end

end
