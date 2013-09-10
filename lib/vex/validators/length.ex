defmodule Vex.Validators.Length do
  @moduledoc """
  Ensure a value's length meets a constraint.

  ## Options

  At least one of the following must be provided:

   * `:min`: The value is at least this long
   * `:max`: The value is at most this long
   * `:in`: The value's length is within this Range
   * `:is`: The value's length is exactly this amount.

  The length for `:is` can be provided instead of the options keyword list.
  The `:is` is available for readability purposes.

  Optional:

   * `:tokenizer`: A function with arity 1 used to split up a
      value for length checking. By default binarys are broken up using
     `String.graphemes` and all other values (eg, lists) are
      passed through intact. See `Vex.Validators.tokens/1`.

  ## Examples

    iex> Vex.Validators.Length.validate("foo", 3)
    :ok
    iex> Vex.Validators.Length.validate("foo", 2)
    {:error, "must have a length of 2"}
    iex> Vex.Validators.Length.validate(nil, [is: 2, allow_nil: true])
    :ok
    iex> Vex.Validators.Length.validate("", [is: 2, allow_blank: true])
    :ok
    iex> Vex.Validators.Length.validate("foo", min: 2, max: 8)
    :ok
    iex> Vex.Validators.Length.validate("foo", min: 4)
    {:error, "must have a length of at least 4"}
    iex> Vex.Validators.Length.validate("foo", max: 2)
    {:error, "must have a length of no more than 2"}
    iex> Vex.Validators.Length.validate("foo", max: 2, message: "must be the right length")
    {:error, "must be the right length"}        
    iex> Vex.Validators.Length.validate("foo", is: 3)
    :ok
    iex> Vex.Validators.Length.validate("foo", is: 2)
    {:error, "must have a length of 2"}   
    iex> Vex.Validators.Length.validate("foo", in: 1..6)
    :ok
    iex> Vex.Validators.Length.validate("foo", in: 8..10)
    {:error, "must have a length between 8 and 10"}
    iex> Vex.Validators.Length.validate("four words are here", max: 4, tokenizer: &String.split/1)
    :ok
  """
  use Vex.Validator

  def validate(value, options) when is_integer(options), do: validate(value, is: options)
  def validate(value, options) when is_range(options),   do: validate(value, in: options)
  def validate(value, options) when is_list(options) do
    unless_skipping(value, options) do
      tokenizer = Keyword.get(options, :tokenizer, &tokens/1)
      tokens    = tokenizer.(value)
      size      = Kernel.length(tokens)
      limits    = bounds(options)
      {findings, default_message} = case limits do
        {nil, nil}   -> raise "Missing length validation range"
        {same, same} -> {size == same, "must have a length of #{same}"}
        {nil, max}   -> {size <= max, "must have a length of no more than #{max}"}
        {min, nil}   -> {min <= size, "must have a length of at least #{min}"}
        {min, max}   -> {min <= size and size <= max, "must have a length between #{min} and #{max}"}
      end
      result findings, message(options, default_message)
    end
  end

  defp bounds(options) do
    is = Keyword.get(options, :is)
    min = Keyword.get(options, :min)
    max = Keyword.get(options, :max)
    range = Keyword.get(options, :in)
    cond do
      is -> {is, is}
      min -> {min, max}
      max -> {min, max}
      range -> {range.first, range.last}
      true -> {nil, nil}
    end
  end

  defp tokens(value) when is_binary(value), do: String.graphemes(value)
  defp tokens(value), do: value  

  defp result(true, _), do: :ok
  defp result(false, message), do: {:error, message}
end