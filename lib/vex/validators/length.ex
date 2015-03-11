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
   * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

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

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Length.__validator__(:message_fields)
      [value: "Bad value", tokens: "Tokens from value", size: "Number of tokens", min: "Minimum acceptable value", max: "Maximum acceptable value"]

  An example:

      iex> Vex.Validators.Length.validate("hello my darling", min: 4, tokenizer: &String.split/1,
      ...>                                                    message: "<%= length tokens %> words isn't enough")
      {:error, "3 words isn't enough"}

  """
  use Vex.Validator

  @message_fields [value: "Bad value", tokens: "Tokens from value", size: "Number of tokens", min: "Minimum acceptable value", max: "Maximum acceptable value"]
  def validate(value, options) when is_integer(options), do: validate(value, is: options)
  def validate(value, min..max), do: validate(value, in: min..max)
  def validate(value, options) when is_list(options) do
    unless_skipping(value, options) do
      tokenizer = Keyword.get(options, :tokenizer, &tokens/1)
      tokens    = if !Vex.Blank.blank?(value), do: tokenizer.(value), else: []
      size      = Kernel.length(tokens)
      {lower, upper} = limits = bounds(options)
      {findings, default_message} = case limits do
        {nil, nil}   -> raise "Missing length validation range"
        {same, same} -> {size == same, "must have a length of #{same}"}
        {nil, max}   -> {size <= max, "must have a length of no more than #{max}"}
        {min, nil}   -> {min <= size, "must have a length of at least #{min}"}
        {min, max}   -> {min <= size and size <= max, "must have a length between #{min} and #{max}"}
      end
      result findings, message(options, default_message, value: value, tokens: tokens, size: size, min: lower, max: upper)
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
