defmodule Vex.Validators.Each do
  @moduledoc """
  Ensure all members of a collection pass one or more validations.

  ## Options

   * Validator identifiers
   *
   * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

   The list can be provided in place of the keyword list if no other options are needed.

  ## Examples

      iex> Vex.Validators.Each.validate([1, 2], &is_integer/1)
      :ok
      iex> Vex.Validators.Each.validate([1, 4, 5], each: [inclusion: [1, 2, 3]])
      {:error, "values 4 and 5 must be one of [1, 2, 3]"}
      iex> Vex.Validators.Each.validate([1, 4], each: &(&1 < 2))
      {:error, "value 4 must be valid"}
      iex> Vex.Validators.Each.validate([1, 4], each: [by: [function: &(&1 < 2), message: "must be < 2"]])
      {:error, "value 4 must be < 2"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Each.__validator__(:message_fields)
      [all_values: "All values", bad_values: "The bad values"]

  An example:

      iex> Vex.Validators.Each.validate([1, 4], in: [1, 2, 3], message: "all members of <%= inspect all_values %> must one of [1, 2, 3]")
      {:error, ~S(all members of [1, 4] must be one of [1, 2, 3])}

  """
  use Vex.Validator

  @message_fields [all_values: "All values", bad_values: "The bad values"]
  def validate(values, func) when is_function(func) do
    validate(values, by: func)
  end
  def validate(values, options) when is_list(options) do
    validate(values, nil, options)
  end

  def validate(values, context, func) when is_function(func) do
    validate(values, context, by: func)
  end
  def validate(values, context, options) when is_list(options) do
    unless_skipping(values, options) do
      case do_validate(values, context, options) do
        [] ->
          :ok
        bad_values ->
          {
            :error,
            message(options, "must have all members be valid",
                    all_values: values,
                    bad_values: bad_values)
          }
      end
    end
  end

  defp do_validate(values, context, options) when is_map(values) do
    values
    |> Map.values
    |> do_validate(context, options)
  end
  defp do_validate(values, context, options) when is_list(values) do
    for value <- values, !Vex.valid?(value, options), into: [], do: value
  end

end
