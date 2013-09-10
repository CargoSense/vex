defmodule Vex.Validators.Acceptance do
  @moduledoc """
  Ensure an attribute is set to a positive (or custom) value.

  For use especially with "acceptance of terms" checkboxes in
  web applications.

  ## Options

   * `:as`: Optional. A custom value (eg, `"yes"`).
     By default any "truthy" value constitutes acceptance.

  ## Examples

    iex> Vex.Validators.Acceptance.validate(1, true)
    :ok
    iex> Vex.Validators.Acceptance.validate(nil, true)
    {:error, "must be accepted"}
    iex> Vex.Validators.Acceptance.validate(nil, message: "must be accepted!")
    {:error, "must be accepted!"}    
    iex> Vex.Validators.Acceptance.validate(1, [as: "yes"])
    {:error, %s(must be accepted with `"yes"`)}
    iex> Vex.Validators.Acceptance.validate("verily", [as: "verily"])
    :ok
  """
  use Vex.Validator

  def validate(value, true), do: result(!!value, "must be accepted")
  def validate(value, options) when is_list(options) do
    criteria = Keyword.get(options, :as)
    check = if criteria, do: value == criteria, else: !!value
    result(check, message(options, "must be accepted with `#{inspect criteria}`"))
  end

  defp result(true, _), do: :ok
  defp result(false, message) do
    {:error, message}
  end
end