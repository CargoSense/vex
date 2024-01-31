defmodule TypeTest do
  use ExUnit.Case

  defmodule Dummy do
    defstruct [:value]
  end

  test "simple types" do
    port = Port.list |> List.first
    valid_cases = [
      {1,        :any},
      {"a",      :any},
      {1,        :number},
      {1,        :integer},
      {nil,      nil},
      {"a",      :binary},
      {"a",      :bitstring},
      {1.1,      :float},
      {1.1,      :number},
      {:foo,     :atom},
      {&self/0,  :function},
      {{1, 2},   :tuple},
      {[1, 2],   :list},
      {%{a: 1},  :map},
      {self,     :pid},
      {make_ref, :reference},
      {port,     :port},
      {1,        [:binary, :integer]},
      {nil,      [nil, :integer]},
      {"a",      [:binary, :atom]},
      {:a,       [:binary, :atom]},
      {"hello",  :string},
      {~r/foo/,  Regex},
      {%Dummy{}, Dummy}
    ]
    invalid_cases = [
      {1,                 :binary},
      {1,                 :float},
      {1,                 nil},
      {nil,               :atom},
      {1.1,               :integer},
      {self,              :reference},
      {{1, 2},            :list},
      {{1, 2},            :map},
      {[1, 2],            :tuple},
      {%{a: 2},           :list},
      {<<239, 191, 191>>, :string},
      {~r/foo/,           :string},
      {:a,                [:binary, :integer]}
    ]

    run_cases(valid_cases, invalid_cases)
  end

  test "complex types" do
    valid_cases = [
      {&self/0,                  function: 0},
      {[1, 2,],                  list: :integer},
      {[1, 2, nil],              list: [nil, :number]},
      {[a: 1, b: 2],             list: [tuple: {:atom, :number}]},
      {%{:a => "a", "b" => nil}, map: {[:atom, :binary], [:binary, nil]}}
    ]
    invalid_cases = [
      {[a: 1, b: "a"],         list: [tuple: {:atom, :number}]},
      {%{1 => "a", "b" => 1},  map: {[:atom, :binary], [:binary, :integer]}},
      {%{:a => 1.1, "b" => 1}, map: {[:atom, :binary], [:binary, :integer]}}
    ]
    run_cases(valid_cases, invalid_cases)
  end

  test "deeply nested type" do
    valid_value = %{a: %{1 => [a: [%{"a" => [a: [1, 2.2, 3]], "b" => nil}]]}}
    invalid_value = %{a: %{1 => [a: [%{"a" => [a: [1, 2.2, "3"]]}]]}}
    other_invalid_value = %{a: %{1 => [a: [%{"a" => [a: [1, 2.2, nil]]}]]}}
    type = [map: {:atom, [map: {:integer, [list: [tuple: {:atom, [list: [map: {:binary, [nil, [list: [tuple: {:atom, [list: [:integer, :float]]}]]]}]]}]]}]}]
    run_cases([{valid_value, type}], [{invalid_value, type}, {other_invalid_value, type}])
  end

  test "default message" do
    expected = [{:error, :foo, :type, "must be of type :integer"}]
    assert Vex.errors(%{foo: "bar"}, foo: [type: [is: :integer]]) == expected
    expected = [{:error, :foo, :type, "must be of type :atom, :string or :list"}]
    assert Vex.errors(%{foo: 1}, foo: [type: [is: [:atom, :string, :list]]]) == expected
    expected = [{:error, :foo, :type, "value 1 is not a string"}]
    message = "value <%= value %> is not a string"
    assert Vex.errors(%{foo: 1}, foo: [type: [is: :string, message: message]]) == expected
  end

  defp run_cases(valid_cases, invalid_cases) do
    Enum.each valid_cases, fn {value, type} ->
      assert Vex.valid?([foo: value], foo: [type: [is: type]])
    end

    Enum.each invalid_cases, fn {value, type} ->
      refute Vex.valid?([foo: value], foo: [type: [is: type]])
    end
  end
end
