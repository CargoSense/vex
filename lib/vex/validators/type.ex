defmodule Vex.Validators.Type do
 @moduledoc """
  Ensure the value has the correct type.

  The type can be provided in the following form:

  * `type`: An atom representing the type.
     It can be any of the `TYPE` in Elixir `is_TYPE` functions.
     `:any` is treated as a special case and accepts any type.
  * `[type]`: A list of types as described above. When a list is passed,
     the value will be valid if it any of the types in the list.
  * `type: inner_type`: Type should be either `map`, `list`, `tuple`, or `function`.
    The usage are as follow

      * `function: arity`: checks if the function has the correct arity.
      * `map: {key_type, value_type}`: checks keys and value in the map with the provided types.
      * `list: type`: checks every element in the list for the given types.
      * `tuple: {type_a, type_b}`: check each element of the tuple with the provided types,
        the types tuple should be the same size as the tuple itself.

  ## Options

   * `:is`:      Required. The type of the value, in the format described above.
   * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

  ## Examples

      iex> Vex.Validators.Type.validate(1, is: :binary)
      {:error, "must be of type :binary"}
      iex> Vex.Validators.Type.validate(1, is: :number)
      :ok
      iex> Vex.Validators.Type.validate(nil, is: nil)
      :ok
      iex> Vex.Validators.Type.validate(1, is: :integer)
      :ok
      iex> Vex.Validators.Type.validate("foo"", is: :binary)
      :ok
      iex> Vex.Validators.Type.validate([1, 2, 3], is: [list: :integer])
      :ok
      iex> Vex.Validators.Type.validate(%{:a => 1, "b" => 2, 3 => 4}, is: :map)
      :ok
      iex> Vex.Validators.Type.validate(%{:a => 1, "b" => 2}, is: [map: {[:binary, :atom], :any}])
      :ok
      iex> Vex.Validators.Type.validate(%{"b" => 2, 3 => 4}, is: [map: {[:binary, :atom], :any}])
      {:error, "must be of type {:map, {[:binary, :atom], :any}}"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Type.__validator__(:message_fields)
      [value: "The bad value"]

  An example:

      iex> Vex.Validators.Type.validate([1], is: :binary, message: "<%= inspect value %> is not a string")
      {:error, "[1] is not a string"}
  """
  use Vex.Validator

  @message_fields [value: "The bad value"]

  @doc """
  Validates the value against the given type.
  See the module documentation for more info.
  """
  @spec validate(any, Keyword.t) :: :ok | {:error, String.t}
  def validate(value, options) when is_list(options) do
    acceptable_types = Keyword.get(options, :is, [])
    if do_validate(value, acceptable_types) do
      :ok
    else
      message = "must be of type #{acceptable_type_str(acceptable_types)}"
      {:error, message(options, message, value: value)}
    end
  end

  # Allow any type, useful for composed types
  defp do_validate(_value, :any), do: true

  # Handle nil
  defp do_validate(nil, nil),   do: true
  defp do_validate(nil, :atom), do: false

  # Simple types
  defp do_validate(value, :atom)      when is_atom(value),      do: true
  defp do_validate(value, :number)    when is_number(value),    do: true
  defp do_validate(value, :integer)   when is_integer(value),   do: true
  defp do_validate(value, :float)     when is_float(value),     do: true
  defp do_validate(value, :binary)    when is_binary(value),    do: true
  defp do_validate(value, :bitstring) when is_bitstring(value), do: true
  defp do_validate(value, :tuple)     when is_tuple(value),     do: true
  defp do_validate(value, :list)      when is_list(value),      do: true
  defp do_validate(value, :map)       when is_map(value),       do: true
  defp do_validate(value, :function)  when is_function(value),  do: true
  defp do_validate(value, :reference) when is_reference(value), do: true
  defp do_validate(value, :port)      when is_port(value),      do: true
  defp do_validate(value, :pid)       when is_pid(value),       do: true
  defp do_validate(%{__struct__: module}, module),              do: true

  # Complex types
  defp do_validate(value, :string) when is_binary(value) do
    String.valid?(value)
  end

  defp do_validate(value, function: arity) when is_function(value, arity), do: true

  defp do_validate(list, list: type) when is_list(list) do
    Enum.all?(list, &(do_validate(&1, type)))
  end
  defp do_validate(value, map: {key_type, value_type}) when is_map(value) do
    Enum.all? value, fn {k, v} ->
      do_validate(k, key_type) && do_validate(v, value_type)
    end
  end
  defp do_validate(tuple, tuple: types)
      when is_tuple(tuple) and is_tuple(types) and tuple_size(tuple) == tuple_size(types) do
    Enum.all? Enum.zip(Tuple.to_list(tuple), Tuple.to_list(types)), fn {value, type} ->
      do_validate(value, type)
    end
  end

  # Accept multiple types
  defp do_validate(value, acceptable_types) when is_list(acceptable_types) do
    Enum.any?(acceptable_types, &(do_validate(value, &1)))
  end

  # Fail if nothing above matched
  defp do_validate(_value, _type), do: false


  defp acceptable_type_str([acceptable_type]), do: inspect(acceptable_type)
  defp acceptable_type_str(acceptable_types) when is_list(acceptable_types) do
    last_type = acceptable_types |> List.last |> inspect
    but_last =
      acceptable_types
      |> Enum.take(Enum.count(acceptable_types) - 1)
      |> Enum.map(&inspect/1)
      |> Enum.join(", ")
    "#{but_last} or #{last_type}"
  end
  defp acceptable_type_str(acceptable_type), do: inspect(acceptable_type)
end
