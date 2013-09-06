defmodule Vex.Validations do

  def validate(value, :presence, false), do: Vex.Blank.blank?(value)
  def validate(value, :presence, true),  do: !Vex.Blank.blank?(value)

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


  def validate(value, :format, [with: format]) do
    Regex.match? format, value
  end
  def validate(value, :format, format) do
    validate(value, :format, [with: format])
  end

  def validate(value, :length, options) when is_binary(value) do
    validate(String.to_char_list!(value), :length, options)
  end
  def validate(value, :length, [min: min]) do
    value |> length >= min
  end
  def validate(value, :length, [max: max]) do
    value |> length <= max
  end
  
  def validate(value, :length, [min: min, max: max]) do
    validate(value, :length, [min: min]) and validate(value, :length, [max: max])
  end
  def validate(value, :length, [in: {min, max}]) do
    validate(value, :length, [min: min]) and validate(value, :length, [max: max])
  end
  def validate(value, :length, [in: Range[first: min, last: max]]) do
    validate(value, :length, [min: min]) and validate(value, :length, [max: max])
  end

  def validate(values, :confirmation, true) do
    values |> Enum.uniq |> length == 1
  end

  def validate(value, :validated_by, func) do
    func.(value)
  end

end