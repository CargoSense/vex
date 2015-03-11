defmodule Vex.Validators.Exclusion do
  @moduledoc """
  Ensure a value is not a member of a list of values.

  ## Options

   * `:in`: The list.
   * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

   The list can be provided in place of the keyword list if no other options are needed.

  ## Examples

      iex> Vex.Validators.Exclusion.validate(1, [1, 2, 3])
      {:error, "must not be one of [1, 2, 3]"}
      iex> Vex.Validators.Exclusion.validate(1, [in: [1, 2, 3]])
      {:error, "must not be one of [1, 2, 3]"}
      iex> Vex.Validators.Exclusion.validate(1, [in: [1, 2, 3], message: "<%= value %> shouldn't be in <%= inspect list %>"])
      {:error, "1 shouldn't be in [1, 2, 3]"}
      iex> Vex.Validators.Exclusion.validate(4, [1, 2, 3])
      :ok
      iex> Vex.Validators.Exclusion.validate("a", ~w(a b c))
      {:error, ~S(must not be one of ["a", "b", "c"])}
      iex> Vex.Validators.Exclusion.validate("a", in: ~w(a b c), message: "must not be abc, talkin' 'bout 123")
      {:error, "must not be abc, talkin' 'bout 123"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Exclusion.__validator__(:message_fields)
      [value: "The bad value", list: "List"]

  An example:

      iex> Vex.Validators.Exclusion.validate("a", in: ~w(a b c), message: "<%= inspect value %> is a disallowed value")
      {:error, ~S("a" is a disallowed value)}
  """
  use Vex.Validator

  @message_fields [value: "The bad value", list: "List"]
  def validate(value, options) when is_list(options) do
    if Keyword.keyword?(options) do
      unless_skipping(value, options) do
        list = Keyword.get options, :in
        result !Enum.member?(list, value), message(options, "must not be one of #{inspect list}",
                                                   value: value, list: list)
      end
    else
      validate(value, [in: options])
    end
  end

  defp result(true, _), do: :ok
  defp result(false, message), do: {:error, message}

end
