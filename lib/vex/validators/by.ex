defmodule Vex.Validators.By do
  @moduledoc """
  Ensure a value meets a custom criteria.

  Provide a function that will accept a value and return a true/false result.

  ## Options

  None, a function with arity 1 must be provided.

  ## Examples

    iex> Vex.Validators.By.validate(2, &(&1 == 2))
    :ok
    iex> Vex.Validators.By.validate(3, &(&1 == 2))
    {:error, "must be valid"}
    iex> Vex.Validators.By.validate(["foo", "foo"], &is_list/1)
    :ok
    iex> Vex.Validators.By.validate("sgge", fn (word) -> word |> String.reverse == "eggs" end)
    :ok
    iex> Vex.Validators.By.validate(nil, [function: &is_list/1, allow_nil: true])
    :ok
    iex> Vex.Validators.By.validate({}, [function: &is_list/1, allow_blank: true])
    :ok
    iex> Vex.Validators.By.validate([1], [function: &is_list/1, message: "must be a list"])
    :ok    
    iex> Vex.Validators.By.validate("a", [function: &is_list/1, message: "must be a list"])
    {:error, "must be a list"}
  """
  use Vex.Validator
  
  def validate(value, func) when is_function(func), do: validate(value, function: func)
  def validate(value, options) do
    unless_skipping(value, options) do
      message = Keyword.get(options, :message, "must be valid")
      function = Keyword.get(options, :function)
      if function.(value), do: :ok, else: {:error, message}
    end
  end
end