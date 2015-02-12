defmodule NestedTest do
  use ExUnit.Case

  test "nested" do
    assert Vex.valid?([author: [name: "Foo"]], %{[:author, :name]  => [presence: true]})

    nested_errors = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors == Vex.errors([author: [name: ""]], %{[:author, :name]  => [presence: true]})
  end

end
