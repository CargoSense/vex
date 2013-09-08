defmodule Vex.Validators.Acceptance do
  @moduledoc """
  Ensure an attribute is set to a positive (or custom) value.

  For use especially with "acceptance of terms" checkboxes in
  web applications.

  ## Options

   * `:accept`: Optional. A custom value (eg, `"yes"`).
     By default any "truthy" value constitutes acceptance.

  ## Examples

    iex> Vex.Validators.Acceptance.validate(1, true)
    :ok
    iex> Vex.Validators.Acceptance.validate(nil, true)
    {:error, "must be accepted with `true`"}
    iex> Vex.Validators.Acceptance.validate(1, [as: "yes"])
    {:error, %s(must be accepted with `"yes"`)}
    iex> Vex.Validators.Acceptance.validate("verily", [as: "verily"])
    :ok
  """

  def validate(value, true), do: result(!!value, true)
  def validate(value, [as: criteria]), do: result(value == criteria, criteria)

  defp result(true, _), do: :ok
  defp result(false, criteria), do: {:error, "must be accepted with `#{inspect criteria}`"}
end