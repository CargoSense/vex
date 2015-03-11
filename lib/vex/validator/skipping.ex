defmodule Vex.Validator.Skipping do

  @doc """
  Checks for allowing blank/nil values, skipping validations.
  """
  defmacro unless_skipping(value, options, do: unskipped) do
    quote do
      if skip?(unquote(value), unquote(options)) do
        :ok
      else
        unquote(unskipped)
      end
    end
  end

  @doc """
  If a validation can be skipped, basoed on the value and options given.

  ## Examples

      iex> Vex.Validator.Skipping.skip?("", allow_nil: true)
      false
      iex> Vex.Validator.Skipping.skip?("", allow_blank: true)
      true
      iex> Vex.Validator.Skipping.skip?(nil, allow_nil: true)
      true
      iex> Vex.Validator.Skipping.skip?(nil, allow_blank: true)
      true
      iex> Vex.Validator.Skipping.skip?(nil, allow_blank: true, allow_nil: true)
      true
      iex> Vex.Validator.Skipping.skip?("", allow_blank: true, allow_nil: true)
      true
      iex> Vex.Validator.Skipping.skip?(1, allow_nil: true)
      false
      iex> Vex.Validator.Skipping.skip?(1, allow_blank: true)
      false
      iex> Vex.Validator.Skipping.skip?(1, allow_blank: true, allow_nil: true)
      false
      iex> Vex.Validator.Skipping.skip?(1, allow_blank: true, allow_nil: true)
      false
  """
  def skip?(value, options) do
    cond do
      Keyword.get(options, :allow_blank) -> Vex.Blank.blank?(value)
      Keyword.get(options, :allow_nil)   -> value == nil
      true -> false
    end
  end
end
