defmodule NestedTestRecord do
  defstruct author: nil
  use Vex.Struct

  validates [:author, :name], presence: true
end

defmodule NestedTest do
  use ExUnit.Case

  test "keyword list, nested" do
    assert Vex.valid?([author: [name: "Foo"]], %{[:author, :name]  => [presence: true]})
    assert Vex.valid?([author: %{name: "Foo"}], %{[:author, :name]  => [presence: true]})

    nested_errors_list = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_list == Vex.errors([author: [name: ""]], %{[:author, :name]  => [presence: true]})

    nested_errors_mixed = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_mixed == Vex.errors([author: %{name: ""}], %{[:author, :name]  => [presence: true]})
  end

  test "keyword list, nested with _vex" do
    assert Vex.valid?([author: [name: "Foo"], _vex: %{[:author, :name]  => [presence: true]}])
    assert Vex.valid?([author: %{name: "Foo"}, _vex: %{[:author, :name]  => [presence: true]}])

    nested_errors_list = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_list == Vex.errors([author: [name: ""], _vex: %{[:author, :name]  => [presence: true]}])

    nested_errors_mixed = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_mixed == Vex.errors([author: %{name: ""}, _vex: %{[:author, :name]  => [presence: true]}])
  end

  test "keyword list, nested in Record" do
    assert Vex.valid?(%NestedTestRecord{author: [name: "Foo"]})

    nested_errors = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors == Vex.errors(%NestedTestRecord{author: [name: ""]})
  end

  test "map, nested" do
    assert Vex.valid?(%{author: %{name: "Foo"}}, %{[:author, :name]  => [presence: true]})
    assert Vex.valid?(%{author: [name: "Foo"]}, %{[:author, :name]  => [presence: true]})

    nested_errors_map = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_map == Vex.errors(%{author: %{name: ""}}, %{[:author, :name]  => [presence: true]})

    nested_errors_mixed = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_mixed == Vex.errors(%{author: [name: ""]}, %{[:author, :name]  => [presence: true]})
  end

  test "map, nested with _vex" do
    assert Vex.valid?(%{author: %{name: "Foo"}, _vex: %{[:author, :name]  => [presence: true]}})
    assert Vex.valid?(%{author: [name: "Foo"], _vex: %{[:author, :name]  => [presence: true]}})

    nested_errors_map = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_map == Vex.errors(%{author: %{name: ""}, _vex: %{[:author, :name]  => [presence: true]}})

    nested_errors_mixed = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors_mixed == Vex.errors(%{author: [name: ""], _vex: %{[:author, :name]  => [presence: true]}})
  end

  test "map, nested in Record" do
    assert Vex.valid?(%NestedTestRecord{author: %{name: "Foo"}})

    nested_errors = [{:error, [:author, :name], :presence, "must be present"}]
    assert nested_errors == Vex.errors(%NestedTestRecord{author: %{name: ""}})
  end
end
