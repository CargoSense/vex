defmodule Vex.Validators.Each do
  @moduledoc """
  Run the validation options across each item in the enumerable.

  ## Examples

      iex> Vex.Validators.Each.validate([1, 2], &is_integer/1)
      :ok

      iex> Vex.Validators.Each.validate(
      ...>   %{a: 1, b: 2}, fn ({k, v}) -> is_atom(k) and is_integer(v) end)
      :ok

      iex> Vex.Validators.Each.validate([1, :b], &is_integer/1)
      {:error, ["must be valid"]}

      iex> Vex.Validators.Each.validate(1, &is_integer/1)
      {:error, :not_enumerable}

      iex> Vex.Validators.Each.validate([1, 2], [validators: &is_integer/1])
      :ok

      iex> Vex.Validators.Each.validate(
      ...>   [1, 2], [validators: [by: &is_integer/1], allow_nil: true])
      :ok

      iex> Vex.Validators.Each.validate(
      ...>   nil, [validators: [by: &is_integer/1], allow_nil: true])
      :ok
  """
  use Vex.Validator

  @validators_key :validators


  def validate(list, func) when is_function(func) do
    validate(list, [{@validators_key, func}])
  end
  def validate(list, options) do
    unless_skipping(list, options) do
      validators = Dict.fetch!(options, @validators_key)
      try do
        list
          |> Enum.map(&Vex.result(&1, validators))
          |> List.flatten()
          |> Enum.filter(fn ({:ok, _, _}) -> false; (_) -> true end)
      rescue
        Protocol.UndefinedError ->
          {:error, :not_enumerable}
       else
        [] ->
          :ok
        errors when is_list(errors) ->
          {:error, (for {:error, _, _, message} <- errors, do: message)}
      end
    end
  end
end
