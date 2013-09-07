defmodule Vex.Validators do
  import Vex.Skipping

  @doc """
  Ensure a value is present.

  Vex uses the `Vex.Blank` protocol to determine "presence."
  Notably, empty strings and collections are not considered present.

  ## Options

  None.

  ## Examples

    iex> Vex.Validators.presence(1, true)
    true
    iex> Vex.Validators.presence(nil, true)
    false
    iex> Vex.Validators.presence(false, true)
    false
    iex> Vex.Validators.presence("", true)
    false
    iex> Vex.Validators.presence([], true)
    false 
    iex> Vex.Validators.presence([], true)
    false
    iex> Vex.Validators.presence([1], true)
    true 
    iex> Vex.Validators.presence({1}, true)
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

    iex> Vex.Validators.absence(1, true)
    false
    iex> Vex.Validators.absence(nil, true)
    true
    iex> Vex.Validators.absence(false, true)
    true
    iex> Vex.Validators.absence("", true)
    true
    iex> Vex.Validators.absence([], true)
    true 
    iex> Vex.Validators.absence([], true)
    true
    iex> Vex.Validators.absence([1], true)
    false 
    iex> Vex.Validators.absence({1}, true)
    false    
  """
  def absence(value, true), do: Vex.Blank.blank?(value)

  @doc """
  Ensure a value is a member of a list of values.

  ## Options

   * `:in`: The list.

   The list can be provided instead of the keyword list.
   The `:in` is available for readability purposes.

  ## Examples

    iex> Vex.Validators.inclusion(1, [1, 2, 3])
    true
    iex> Vex.Validators.inclusion(1, [in: [1, 2, 3]])
    true
    iex> Vex.Validators.inclusion(4, [1, 2, 3])
    false
    iex> Vex.Validators.inclusion("a", %w(a b c))
    true
    iex> Vex.Validators.inclusion(nil, %w(a b c))
    false
    iex> Vex.Validators.inclusion(nil, [in: %w(a b c), allow_nil: true])
    true
    iex> Vex.Validators.inclusion("", [in: %w(a b c), allow_blank: true])
    true

  """
  def inclusion(value, options) when is_list(options) do
    if Keyword.keyword?(options) do
      unless_skipping(value, options) do
        list = Keyword.get options, :in
        Enum.member? list, value
      end
    else
      inclusion(value, [in: options])
    end
  end

  @doc """
  Ensure a value is not a member of a list of values.

  ## Options

   * `:in`: The list.

   The list can be provided instead of the keyword list.
   The `:in` is available for readability purposes.

  ## Examples

    iex> Vex.Validators.exclusion(1, [1, 2, 3])
    false
    iex> Vex.Validators.exclusion(1, [in: [1, 2, 3]])
    false
    iex> Vex.Validators.exclusion(4, [1, 2, 3])
    true
    iex> Vex.Validators.exclusion("a", %w(a b c))
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

    iex> Vex.Validators.acceptance(1, true)
    true
    iex> Vex.Validators.acceptance(nil, true)
    false
    iex> Vex.Validators.acceptance(1, [as: "yes"])
    false
    iex> Vex.Validators.acceptance("verily", [as: "verily"])
    true
  """
  def acceptance(value, true), do: !!value
  def acceptance(value, [as: criteria]), do: value == criteria

  @doc """
  Ensure a value matches a regular expression.

  ## Options

   * `:with`: The regular expression.

  The regular expression can be provided instead of the keyword list.
  The `:with` is available for readability purposes.

  ## Examples

    iex> Vex.Validators.format("foo", %r"^f")
    true
    iex> Vex.Validators.format("foo", %r"o{3,}")
    false
    iex> Vex.Validators.format("foo", [with: %r"^f"])
    true
    iex> Vex.Validators.format("", [with: %r"^f", allow_blank: true])
    true
    iex> Vex.Validators.format(nil, [with: %r"^f", allow_nil: true])
    true    
  """
  def format(value, format) when is_regex(format), do: format(value, with: format)
  def format(value, options) do
    unless_skipping(value, options) do
      Regex.match?(Keyword.get(options, :with), value)
    end
  end

  @doc """
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

    iex> Vex.Validators.length("foo", 3)
    true
    iex> Vex.Validators.length("foo", 2)
    false
    iex> Vex.Validators.length(nil, [is: 2, allow_nil: true])
    true
    iex> Vex.Validators.length("", [is: 2, allow_blank: true])
    true    
    iex> Vex.Validators.length("foo", min: 2, max: 8)
    true
    iex> Vex.Validators.length("foo", min: 4)
    false
    iex> Vex.Validators.length("foo", max: 2)
    false
    iex> Vex.Validators.length("foo", is: 3)
    true
    iex> Vex.Validators.length("foo", is: 2)
    false   
    iex> Vex.Validators.length("foo", in: 1..6)
    true
    iex> Vex.Validators.length("foo", in: 8..10)
    false
    iex> Vex.Validators.length("four words are here", max: 4, tokenizer: &String.split/1)
    true
  """
  def length(value, options) when is_integer(options), do: length(value, is: options)
  def length(value, options) when is_range(options),   do: length(value, in: options)
  def length(value, options) when is_list(options) do
    unless_skipping(value, options) do
      tokenizer = Keyword.get(options, :tokenizer, &tokens/1)
      tokens    = tokenizer.(value)
      size      = Kernel.length(tokens)
      case bounds(options) do
        {^size, ^size} -> true
        {nil, max}   -> size <= max
        {min, nil}   -> min <= size
        {min, max}   -> min <= size and size <= max
        {nil, nil}   -> raise "Missing length validation range"      
      end
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

  @doc """
  Ensure a value, if provided, is equivalent to a second value.

  Generally used to check, eg, a password and password
  confirmation.

  Note: This validator is treated differently by Vex, in that
  two values are passed to it.

  ## Options

  None.

  ## Examples

    iex> Vex.Validators.confirmation(["foo", "bar"], true)
    false
    iex> Vex.Validators.confirmation(["foo", "foo"], true)
    true
    iex> Vex.Validators.confirmation([nil, "bar"], true)
    true
    iex> Vex.Validators.confirmation(["foo", nil], true)
    false
    iex> Vex.Validators.confirmation(["", "unneeded"], [allow_blank: true])
    true    
  """
  def confirmation(values, true), do: confirmation(values, [])
  def confirmation([nil | _], options), do: true
  def confirmation([subject, _] = values, options) do
    unless_skipping(subject, options) do
      values |> Enum.uniq |> length == 1
    end
  end

  @doc """
  Ensure a value meets a custom criteria.

  Provide a function that will accept a value and return a true/false result.

  ## Options

  None, a function with arity 1 must be provided.

  ## Examples

    iex> Vex.Validators.by(2, &(&1 == 2))
    true
    iex> Vex.Validators.by(3, &(&1 == 2))
    false    
    iex> Vex.Validators.by(["foo", "foo"], &is_list/1)
    true
    iex> Vex.Validators.by("sgge", fn (word) -> word |> String.reverse == "eggs" end)
    true
    iex> Vex.Validators.by(nil, [function: &is_list/1, allow_nil: true])
    true
    iex> Vex.Validators.by({}, [function: &is_list/1, allow_blank: true])
    true            
  """
  def by(value, func) when is_function(func), do: by(value, function: func)
  def by(value, options) do
    unless_skipping(value, options) do
      function = Keyword.get(options, :function)
      function.(value)
    end
  end

end