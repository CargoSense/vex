defmodule Vex.Validators.Absence do 
 @moduledoc """
  Ensure a value is absent.

  Vex uses the `Vex.Blank` protocol to determine "absence."
  Notably, empty strings and collections are considered absent.

  ## Options

  None.

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
    iex> Vex.Validators.Absence.validate({1}, message: "can't exist")
    {:error, "can't exist"}
  """
  use Vex.Validator

  def validate(value, options) do
    if Vex.Blank.blank?(value) do
      :ok
    else
      {:error, message(options, "must be absent")}
    end
  end

end