defmodule Vex.Validations do

  def validate(value, :presence, _any),  do: !Vex.Blank.blank?(value)

  def validate(value, :absence, _any),  do: Vex.Blank.blank?(value)

  def validate(value, :inclusion, [in: values]) when is_list(values) do
    Enum.member? values, value
  end
  def validate(value, :inclusion, options) when is_list(options) do
    validate(value, :inclusion, [in: options])
  end

  def validate(value, :exclusion, options) do
    !validate(value, :inclusion, options)
  end

  def validate(value, :acceptance, [accept: criteria]) do
    value == criteria
  end
  def validate(value, :acceptance, _any) do
    !!value
  end

  def validate(value, :format, with: format) do
    Regex.match? format, value
  end
  def validate(value, :format, format) do
    validate(value, :format, with: format)
  end

  defp default_tokenizer(value) when is_binary(value) do
    String.split(value, %r//, trim: true)
  end
  defp default_tokenizer(value), do: value

  def validate(value, :length, min: min) when is_binary(value) do
    value |> default_tokenizer |> length >= min
  end
  def validate(value, :length, max: max) when is_binary(value)  do
    value |> default_tokenizer |> length <= max
  end
  def validate(value, :length, min: min) do
    value |> length >= min
  end
  def validate(value, :length, max: max) do
    value |> length <= max
  end

  def validate(value, :length, [in: settings]) do
    validate(value, :length, settings)
  end
  def validate(value, :length, Range[first: min, last: max]) do
    validate(value, :length, min: min, max: max)
  end
  def validate(value, :length, settings) when is_list(settings) do
    minimum   = Keyword.get settings, :min
    maximum   = Keyword.get settings, :max
    tokenizer = Keyword.get settings, :tokenizer, &default_tokenizer/1
    tokens    = tokenizer.(value)
    case {minimum, maximum} do
      {nil, nil} -> raise "Missing length validation range"
      {nil, max} -> validate(tokens, :length, max: max)
      {min, nil} -> validate(tokens, :length, min: min)
      {min, max} -> validate(tokens, :length, min: min) and validate(tokens, :length, max: max)
    end
  end

  def validate(values, :confirmation, true) do
    values |> Enum.uniq |> length == 1
  end

  def validate(value, :validated_by, func) do
    func.(value)
  end

end