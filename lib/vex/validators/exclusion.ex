defmodule Vex.Validators.Exclusion do
  @moduledoc """
  Ensure a value is not a member of a list of values.

  ## Options

   * `:in`: The list.

   The list can be provided instead of the keyword list.
   The `:in` is available for readability purposes.

  ## Examples

    iex> Vex.Validators.Exclusion.validate(1, [1, 2, 3])
    {:error, "must not be one of [1, 2, 3]"}
    iex> Vex.Validators.Exclusion.validate(1, [in: [1, 2, 3]])
    {:error, "must not be one of [1, 2, 3]"}
    iex> Vex.Validators.Exclusion.validate(4, [1, 2, 3])
    :ok
    iex> Vex.Validators.Exclusion.validate("a", %w(a b c))
    {:error, %s(must not be one of ["a", "b", "c"])}
    iex> Vex.Validators.Exclusion.validate("a", in: %w(a b c), message: "must not be abc, talkin' 'bout 123")
    {:error, "must not be abc, talkin' 'bout 123"}
  """

  use Vex.Validator

  def validate(value, options) when is_list(options) do
    if Keyword.keyword?(options) do
      unless_skipping(value, options) do
        list = Keyword.get options, :in
        result !Enum.member?(list, value), message(options, "must not be one of #{inspect list}")
      end
    else
      validate(value, [in: options])
    end
  end

  defp result(true, _), do: :ok
  defp result(false, message), do: {:error, message}

end