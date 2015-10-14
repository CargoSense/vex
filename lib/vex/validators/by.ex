defmodule Vex.Validators.By do
  @moduledoc """
  Ensure a value meets a custom criteria.

  Provide a function that will accept a value and return a true/false result.

  ## Options

  None, a function with arity 1 must be provided.

     * `:function`: The function to check. Should have an arity of 1 and return true/false.
     * `:message`: Optional. A custom error message. May be in EEx format
       and use the fields described in "Custom Error Messages," below.

  The function can be provided in place of the keyword list if no other options are needed.

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

      iex> Vex.Validators.By.validate(
      ...>   "a", [function: fn (v) when is_list(v) -> :ok
      ...>                      (v) -> {:error, {:not_list, v}} end])
      {:error, {:not_list, "a"}}
      iex> Vex.Validators.By.validate(
      ...>   [], [function: fn (v) when is_list(v) -> :ok
      ...>                     (v) -> {:error, {:not_list, v}} end])
      :ok

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.By.__validator__(:message_fields)
      [value: "The bad value"]

  An example:

      iex> Vex.Validators.By.validate("blah", [function: &is_list/1, message: "<%= inspect value %> isn't a list"])
      {:error, ~S("blah" isn't a list)}
  """
  use Vex.Validator

  @message_fields [value: "The bad value"]
  def validate(value, func) when is_function(func), do: validate(value, function: func)
  def validate(value, options) when is_list(options) do
    validate(value, nil, options)
  end

  @message_fields [value: "The bad value"]
  def validate(value, context, func) when is_function(func), do: validate(value, context, function: func)
  def validate(value, context, options) when is_list(options) do
    unless_skipping(value, options) do
      function = Keyword.get(options, :function)
      case call_function(function, value, context) do
        {:error, reason} ->
          {:error, reason}
        falsy when falsy === false or falsy === nil ->
          {:error, message(options, "must be valid", value: value)}
        _ ->
          :ok
      end
    end
  end

  defp call_function(f, value, _context) when is_function(f, 1), do: f.(value)
  defp call_function(f, value, context) when is_function(f, 2), do: f.(value, context)

end
