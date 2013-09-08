defmodule Vex.Validators.Format do
  @moduledoc """
  Ensure a value matches a regular expression.

  ## Options

   * `:with`: The regular expression.

  The regular expression can be provided instead of the keyword list.
  The `:with` is available for readability purposes.

  ## Examples

    iex> Vex.Validators.Format.validate("foo", %r"^f")
    :ok
    iex> Vex.Validators.Format.validate("foo", %r"o{3,}")
    {:error, "must have the correct format"}
    iex> Vex.Validators.Format.validate("foo", [with: %r"^f"])
    :ok
    iex> Vex.Validators.Format.validate("bar", [with: %r"^f", message: "must start with an f"])
    {:error, "must start with an f"}
    iex> Vex.Validators.Format.validate("", [with: %r"^f", allow_blank: true])
    :ok
    iex> Vex.Validators.Format.validate(nil, [with: %r"^f", allow_nil: true])
    :ok    
  """
  use Vex.Validator

  def validate(value, format) when is_regex(format), do: validate(value, with: format)
  def validate(value, options) do
    unless_skipping(value, options) do
      message = Keyword.get(options, :message, "must have the correct format")
      pattern = Keyword.get(options, :with)
      result Regex.match?(pattern, value), message
    end
  end

  defp result(true, _), do: :ok
  defp result(false, message), do: {:error, message}

end