defmodule Vex.Validators.Presence do 
 @moduledoc """
  Ensure a value is present.

  Vex uses the `Vex.Blank` protocol to determine "presence."
  Notably, empty strings and collections are not considered present.

  ## Options

  None.

  ## Examples

    iex> Vex.Validators.Presence.validate(1, true)
    :ok
    iex> Vex.Validators.Presence.validate(nil, true)
    {:error, "must be present"}
    iex> Vex.Validators.Presence.validate(false, true)
    {:error, "must be present"}
    iex> Vex.Validators.Presence.validate("", true)
    {:error, "must be present"}
    iex> Vex.Validators.Presence.validate([], true)
    {:error, "must be present"}
    iex> Vex.Validators.Presence.validate([], true)
    {:error, "must be present"}
    iex> Vex.Validators.Presence.validate([1], true)
    :ok 
    iex> Vex.Validators.Presence.validate({1}, true)
    :ok
  """
  use Vex.Validator

  def validate(value, options) do
    if Vex.Blank.blank?(value) do
      {:error, "must be present"}
    else
      :ok
    end
  end

end