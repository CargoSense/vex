defmodule Vex.Validators.Number do
  @moduledoc """
  Ensure a value is a number.

  ## Options

  At least one of the following must be provided:

  * `:is`: The value is a number (integer or float) or not.
  * `:equal_to`: The value is a number equal to this number.
  * `:greater_than` : The value is a number greater than this number.
  * `:greater_than_or_equal_to`: The value is a number greater than or equal to this number.
  * `:less_than` : The value is a number less than this number.
  * `:less_than_or_equal_to`: The value is a number less than or equal to this number.

  Optional:

  * `:message`: A custom error message. May be in EEx format and use the fields described
    in [Custom Error Messages](#module-custom-error-messages).
  * `:allow_nil`: A boolean whether to skip this validation for `nil` values.
  * `:allow_blank`: A boolean whether to skip this validation for blank values.

  The `:is` option can be provided in place of the keyword list if no other options are set.
  When multiple options are than the validator will do an `and` logic between them.

  ## Examples

  Examples when using the `:is` option:

      iex> Vex.Validators.Number.validate("not_a_number", is: true)
      {:error, "must be a number"}
      iex> Vex.Validators.Number.validate(3.14, is: true)
      :ok

      iex> Vex.Validators.Number.validate("not_a_number", is: false)
      :ok
      iex> Vex.Validators.Number.validate(3.14, is: false)
      {:error, "must not be a number"}

  Examples when using the boolean value in options for the `:is` option:

      iex> Vex.Validators.Number.validate("not_a_number", true)
      {:error, "must be a number"}
      iex> Vex.Validators.Number.validate(3.14, true)
      :ok

      iex> Vex.Validators.Number.validate("not_a_number", false)
      :ok
      iex> Vex.Validators.Number.validate(3.14, false)
      {:error, "must not be a number"}

  Examples when using the `:equal_to` option:

      iex> Vex.Validators.Number.validate(3.14, equal_to: 1.41)
      {:error, "must be a number equal to 1.41"}
      iex> Vex.Validators.Number.validate(3.14, equal_to: 3.14)
      :ok
      iex> Vex.Validators.Number.validate(3.14, equal_to: 6.28)
      {:error, "must be a number equal to 6.28"}

  Examples when using the `:greater_than` option:

      iex> Vex.Validators.Number.validate(3.14, greater_than: 1.41)
      :ok
      iex> Vex.Validators.Number.validate(3.14, greater_than: 3.14)
      {:error, "must be a number greater than 3.14"}
      iex> Vex.Validators.Number.validate(3.14, greater_than: 6.28)
      {:error, "must be a number greater than 6.28"}

  Examples when using the `:greater_than_or_equal_to` option:

      iex> Vex.Validators.Number.validate(3.14, greater_than_or_equal_to: 1.41)
      :ok
      iex> Vex.Validators.Number.validate(3.14, greater_than_or_equal_to: 3.14)
      :ok
      iex> Vex.Validators.Number.validate(3.14, greater_than_or_equal_to: 6.28)
      {:error, "must be a number greater than or equal to 6.28"}

  Examples when using the `:less_than` option:

      iex> Vex.Validators.Number.validate(3.14, less_than: 1.41)
      {:error, "must be a number less than 1.41"}
      iex> Vex.Validators.Number.validate(3.14, less_than: 3.14)
      {:error, "must be a number less than 3.14"}
      iex> Vex.Validators.Number.validate(3.14, less_than: 6.28)
      :ok

  Examples when using the `:less_than_or_equal_to` option:

      iex> Vex.Validators.Number.validate(3.14, less_than_or_equal_to: 1.41)
      {:error, "must be a number less than or equal to 1.41"}
      iex> Vex.Validators.Number.validate(3.14, less_than_or_equal_to: 3.14)
      :ok
      iex> Vex.Validators.Number.validate(3.14, less_than_or_equal_to: 6.28)
      :ok

  Examples when using the combinations of the above options:

      iex> Vex.Validators.Number.validate("not_a_number", is: true, greater_than: 0, less_than_or_equal_to: 3.14)
      {:error, "must be a number"}
      iex> Vex.Validators.Number.validate(0, is: true, greater_than: 0, less_than_or_equal_to: 3.14)
      {:error, "must be a number greater than 0"}
      iex> Vex.Validators.Number.validate(1.41, is: true, greater_than: 0, less_than_or_equal_to: 3.14)
      :ok
      iex> Vex.Validators.Number.validate(3.14, is: true, greater_than: 0, less_than_or_equal_to: 3.14)
      :ok
      iex> Vex.Validators.Number.validate(6.28, is: true, greater_than: 0, less_than_or_equal_to: 3.14)
      {:error, "must be a number less than or equal to 3.14"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Number.__validator__(:message_fields)
      [                             
        value: "Bad value",         
        is: "Is number",            
        equal_to: "Equal to number",             
        greater_than: "Greater than number",
        greater_than_or_equal_to: "Greater than or equal to number",
        less_than: "Less than number",
        less_than_or_equal_to: "Less than or equal to number"
      ]

  An example:

      iex> Vex.Validators.Number.validate(3.14, less_than: 1.41,
      ...>                                      message: "<%= inspect value %> should be less than <%= less_than %>")
      {:error, "3.14 should be less than 1.41"}
  """

  use Vex.Validator

  @option_keys [
    :is,
    :equal_to,
    :greater_than,
    :greater_than_or_equal_to,
    :less_than,
    :less_than_or_equal_to
  ]

  @message_fields [
    value: "Bad value",
    is: "Is number",
    equal_to: "Equal to number",
    greater_than: "Greater than number",
    greater_than_or_equal_to: "Greater than or equal to number",
    less_than: "Less than number",
    less_than_or_equal_to: "Less than or equal to number"
  ]
  def validate(value, options) when is_boolean(options) do
    validate(value, is: options)
  end

  def validate(value, options) when is_list(options) do
    unless_skipping value, options do
      Enum.reduce_while(options, :ok, fn
        {k, o}, _ when k in @option_keys ->
          case do_validate(value, k, o) do
            :ok ->
              {:cont, :ok}

            {:error, default_message} ->
              fields =
                options
                |> Keyword.take(@option_keys)
                |> Keyword.put(:value, value)
                |> Keyword.put(:less_than, options[:less_than])

              error = {:error, message(options, default_message, fields)}

              {:halt, error}
          end

        _, _ ->
          {:cont, :ok}
      end)
    end
  end

  defp do_validate(_, _, nil), do: :ok
  defp do_validate(v, :is, o) when is_number(v) === o, do: :ok
  defp do_validate(_, :is, true), do: {:error, "must be a number"}
  defp do_validate(_, :is, false), do: {:error, "must not be a number"}

  defp do_validate(_, k, o) when not is_number(o),
    do: raise("Invalid value #{inspect(o)} for option #{k}")

  defp do_validate(v, :equal_to, o) when is_number(v) and v == o, do: :ok
  defp do_validate(_, :equal_to, o), do: {:error, "must be a number equal to #{o}"}
  defp do_validate(v, :greater_than, o) when is_number(v) and v > o, do: :ok
  defp do_validate(_, :greater_than, o), do: {:error, "must be a number greater than #{o}"}
  defp do_validate(v, :greater_than_or_equal_to, o) when is_number(v) and v >= o, do: :ok

  defp do_validate(_, :greater_than_or_equal_to, o),
    do: {:error, "must be a number greater than or equal to #{o}"}

  defp do_validate(v, :less_than, o) when is_number(v) and v < o, do: :ok
  defp do_validate(_, :less_than, o), do: {:error, "must be a number less than #{o}"}
  defp do_validate(v, :less_than_or_equal_to, o) when is_number(v) and v <= o, do: :ok

  defp do_validate(_, :less_than_or_equal_to, o),
    do: {:error, "must be a number less than or equal to #{o}"}
end
