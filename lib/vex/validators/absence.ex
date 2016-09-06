defmodule Vex.Validators.Absence do
 @moduledoc """
  Ensure a value is absent.

  Vex uses the `Vex.Blank` protocol to determine "absence."
  Notably, empty strings and collections are considered absent.

  ## Options

   * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

  ## Examples

      iex> Vex.Validators.Absence.validate(1, true)
      {:error, "must be absent"}
      iex> Vex.Validators.Absence.validate(nil, true)
      :ok
      iex> Vex.Validators.Absence.validate(false, true)
      :ok
      iex> Vex.Validators.Absence.validate("", true)
      :ok
      iex> Vex.Validators.Absence.validate([], true)
      :ok
      iex> Vex.Validators.Absence.validate([], true)
      :ok
      iex> Vex.Validators.Absence.validate([1], true)
      {:error, "must be absent"}
      iex> Vex.Validators.Absence.validate({1}, true)
      {:error, "must be absent"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as :message, can use the following values:

      iex> Vex.Validators.Absence.__validator__(:message_fields)
      [value: "The bad value"]

  An example:

      iex> Vex.Validators.Absence.validate([1], message: "can't be <%= inspect value %>")
      {:error, "can't be [1]"}
  """
  use Vex.Validator

  @message_fields [value: "The bad value"]
  def validate(value, options) do
    if Vex.Blank.blank?(value) do
      :ok
    else
      {:error, message(options, "must be absent", value: value)}
    end
  end

end
