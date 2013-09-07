defmodule Vex.Validations do

  @doc """
  Ensure a value is present.

  Vex uses the `Vex.Blank` protocol to determine "presence."
  Notably, empty strings and collections are not considered present.

  ## Options

  None.

  ## Examples

    iex> Vex.Validations.presence(1, true)
    true
    iex> Vex.Validations.presence(nil, true)
    false
    iex> Vex.Validations.presence(false, true)
    false
    iex> Vex.Validations.presence("", true)
    false
    iex> Vex.Validations.presence([], true)
    false 
    iex> Vex.Validations.presence([], true)
    false
    iex> Vex.Validations.presence([1], true)
    true 
    iex> Vex.Validations.presence({1}, true)
    true    
  """
  def presence(value, true), do: !Vex.Blank.blank?(value)

  @doc """
  Ensure a value is absent.

  Vex uses the `Vex.Blank` protocol to determine "absence."
  Notably, empty strings and collections are considered absent.

  ## Options

  None.

  ## Examples

    iex> Vex.Validations.absence(1, true)
    false
    iex> Vex.Validations.absence(nil, true)
    true
    iex> Vex.Validations.absence(false, true)
    true
    iex> Vex.Validations.absence("", true)
    true
    iex> Vex.Validations.absence([], true)
    true 
    iex> Vex.Validations.absence([], true)
    true
    iex> Vex.Validations.absence([1], true)
    false 
    iex> Vex.Validations.absence({1}, true)
    false    
  """
  def absence(value, true), do: Vex.Blank.blank?(value)

  @doc """
  Ensure a value is a member of a list of values.

  ## Options

   * `:in`: The list.

   The list can be provided instead of the keyword list.
   The `:in` is only provided for readability purposes.

  ## Examples

    iex> Vex.Validations.inclusion(1, [1, 2, 3])
    true
    iex> Vex.Validations.inclusion(1, [in: [1, 2, 3]])
    true
    iex> Vex.Validations.inclusion(4, [1, 2, 3])
    false
    iex> Vex.Validations.inclusion("a", %w(a b c))
    true
  """
  def inclusion(value, [in: values]) when is_list(values) do
    Enum.member? values, value
  end
  def inclusion(value, options) when is_list(options) do
    inclusion(value, [in: options])
  end

  @doc """
  Ensure a value is not a member of a list of values.

  ## Options

   * `:in`: The list.

   The list can be provided instead of the keyword list.
   The `:in` is only provided for readability purposes.

  ## Examples

    iex> Vex.Validations.exclusion(1, [1, 2, 3])
    false
    iex> Vex.Validations.exclusion(1, [in: [1, 2, 3]])
    false
    iex> Vex.Validations.exclusion(4, [1, 2, 3])
    true
    iex> Vex.Validations.exclusion("a", %w(a b c))
    false
  """
  def exclusion(value, options), do: !inclusion(value, options)

  @doc """
  Ensure an attribute is set to a positive (or custom) value.

  For use especially with "acceptance of terms" checkboxes in
  web applications.

  ## Options

   * `:accept`: Optional. A custom value (eg, `"yes"`).
     By default any "truthy" value constitutes acceptance.

  ## Examples

    iex> Vex.Validations.acceptance(1, true)
    true
    iex> Vex.Validations.acceptance(nil, true)
    false
    iex> Vex.Validations.acceptance(1, [accept: "yes"])
    false
    iex> Vex.Validations.acceptance("verily", [accept: "verily"])
    true
  """
  def acceptance(value, true), do: !!value
  def acceptance(value, [accept: criteria]), do: value == criteria

  @doc """
  Ensure a value matches a regular expression.

  ## Options

   * `:with`: The regular expression.

  The regular expression can be provided instead of the keyword list.
  The `:with` is only provided for readability purposes.

  ## Examples

    iex> Vex.Validations.format("foo", %r"^f")
    true
    iex> Vex.Validations.format("foo", %r"o{3,}")
    false
    iex> Vex.Validations.format("foo", [with: %r"^f"])
    true

  """
  def format(value, with: format), do: Regex.match?(format, value)
  def format(value, format), do: format(value, with: format)


  def length(value, min: min), do: value |> tokens |> length >= min
  def length(value, max: max), do: value |> tokens |> length <= max

  def length(value, [in: options]), do: length(value, options)

  def length(value, Range[first: min, last: max]) do
    length(value, min: min, max: max)
  end

  def length(value, options) when is_list(options) do
    minimum   = Keyword.get options, :min
    maximum   = Keyword.get options, :max
    tokenizer = Keyword.get options, :tokenizer, &tokens/1
    tokens    = tokenizer.(value)
    case {minimum, maximum} do
      {nil, nil} -> raise "Missing length validation range"
      {nil, max} -> length(tokens, max: max)
      {min, nil} -> length(tokens, min: min)
      {min, max} -> length(tokens, min: min) and length(tokens, max: max)
    end
  end

  defp tokens(value) when is_binary(value), do: String.graphemes(value)
  defp tokens(value), do: value


  def confirmation(values, true), do: values |> Enum.uniq |> length == 1

  def validated_by(value, func), do: func.(value)


end