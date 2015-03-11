defmodule Vex.Validators.Acceptance do
  @moduledoc """
  Ensure an attribute is set to a positive (or custom) value.

  For use especially with "acceptance of terms" checkboxes in
  web applications.

  ## Options

   * `:as`: Optional. A custom value (eg, `"yes"`).
     By default any "truthy" value constitutes acceptance.
   * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

  ## Examples

      iex> Vex.Validators.Acceptance.validate(1, true)
      :ok
      iex> Vex.Validators.Acceptance.validate(nil, true)
      {:error, "must be accepted"}
      iex> Vex.Validators.Acceptance.validate(nil, message: "must be accepted!")
      {:error, "must be accepted!"}
      iex> Vex.Validators.Acceptance.validate(1, [as: "yes"])
      {:error, ~S(must be accepted with `"yes"`)}
      iex> Vex.Validators.Acceptance.validate("verily", [as: "verily"])
      :ok

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Acceptance.__validator__(:message_fields)
      [value: "The bad value"]

  An example:

      iex> Vex.Validators.Acceptance.validate(nil, message: "<%= inspect value %> doesn't count as accepted")
      {:error, "nil doesn't count as accepted"}

  """
  use Vex.Validator

  @message_fields [value: "The bad value"]
  def validate(value, true), do: result(!!value, "must be accepted")
  def validate(value, options) when is_list(options) do
    criteria = Keyword.get(options, :as)
    check = if criteria, do: value == criteria, else: !!value
    msg = message(options,
                  "must be accepted with `#{inspect criteria}`",
                  value: value)
    result(check, msg)
  end

  defp result(true, _), do: :ok
  defp result(false, message) do
    {:error, message}
  end
end
