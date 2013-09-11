defmodule Vex.Validators.Confirmation do
  @moduledoc """
  Ensure a value, if provided, is equivalent to a second value.

  Generally used to check, eg, a password and password
  confirmation.

  Note: This validator is treated differently by Vex, in that
  two values are passed to it.

  ## Options

  None.

  ## Examples

    iex> Vex.Validators.Confirmation.validate(["foo", "bar"], true)
    {:error, "must match its confirmation"}
    iex> Vex.Validators.Confirmation.validate(["foo", "foo"], true)
    :ok
    iex> Vex.Validators.Confirmation.validate([nil, "bar"], true)
    :ok
    iex> Vex.Validators.Confirmation.validate(["foo", nil], true)
    {:error, "must match its confirmation"}
    iex> Vex.Validators.Confirmation.validate(["foo", nil], message: "must match!")
    {:error, "must match!"}    
    iex> Vex.Validators.Confirmation.validate(["", "unneeded"], [allow_blank: true])
    :ok
  """
  use Vex.Validator

  def validate(values, true), do: validate(values, [])
  def validate([nil | _], _options), do: :ok
  def validate([subject, _] = values, options) when is_list(options) do
    unless_skipping(subject, options) do
      if values |> Enum.uniq |> length == 1 do
        :ok
      else
        {:error, message(options, "must match its confirmation")}
      end
    end
  end

end