defmodule Vex.Validators.Inclusion do
  @moduledoc """
  Ensure a value is a member of a list of values.

  ## Options

   * `:in`: The list.

   The list can be provided instead of the keyword list.
   The `:in` is available for readability purposes.

  ## Examples

    iex> Vex.Validators.Inclusion.validate(1, [1, 2, 3])
    :ok
    iex> Vex.Validators.Inclusion.validate(1, [in: [1, 2, 3]])
    :ok
    iex> Vex.Validators.Inclusion.validate(4, [1, 2, 3])
    {:error, "must be one of [1, 2, 3]"}
    iex> Vex.Validators.Inclusion.validate("a", %w(a b c))
    :ok
    iex> Vex.Validators.Inclusion.validate(nil, %w(a b c))
    {:error, %s(must be one of ["a", "b", "c"])}
    iex> Vex.Validators.Inclusion.validate(nil, [in: %w(a b c), allow_nil: true])
    :ok
    iex> Vex.Validators.Inclusion.validate("", [in: %w(a b c), allow_blank: true])
    :ok

  """
  use Vex.Validator

  def validate(value, options) when is_list(options) do
    if Keyword.keyword?(options) do
      unless_skipping(value, options) do
        list = Keyword.get options, :in
        result Enum.member?(list, value), list
      end
    else
      validate(value, [in: options])
    end
  end

  defp result(true, _), do: :ok
  defp result(false, list), do: {:error, "must be one of #{inspect list}"}

end