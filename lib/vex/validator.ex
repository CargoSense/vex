defmodule Vex.Validator do
  @moduledoc """
  Common validator behavior.
  """

  defmacro __using__(_) do
    quote do
      @behaviour Vex.Validator.Behaviour
      import Vex.Validator.Skipping
      use Vex.Validator.ErrorMessage

      def validate(data, _context, options) do
        validate(data, options)
      end

      defoverridable [validate: 3]
    end
  end

  @doc """
  Determine if a validation should be executed based on any conditions provided

  ## Examples

  If an attribute is/isn't present (non-blank):

      iex> Vex.Validator.validate?([name: "foo", state: "new"], if: :state)
      true
      iex> Vex.Validator.validate?([name: "foo", state: "new"], unless: :state)
      false

  If an attribute does/doesn't match a value:

      iex> Vex.Validator.validate?([name: "foo", state: "new"], if: [state: "new"])
      true
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], if: [state: "new"])
      false
      iex> Vex.Validator.validate?([name: "foo", state: "new"], unless: [state: "new"])
      false
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], unless: [state: "new"])
      true

  If the data does/doesn't match another custom condition:

      iex> Vex.Validator.validate?([name: "foo"], if: &(&1[:name] == "foo"))
      true
      iex> Vex.Validator.validate?([name: "foo"], unless: &(&1[:name] == "foo"))
      false
      iex> Vex.Validator.validate?([name: "foo"], if: &(&1[:name] != "foo"))
      false
      iex> Vex.Validator.validate?([name: "foo"], unless: &(&1[:name] != "foo"))
      true

  If the data does/doesn't match a list of conditions:

      iex> Vex.Validator.validate?([name: "foo", state: "new"], if: [name: "foo", state: "new"])
      true
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], if: [name: "foo", state: "new"])
      false
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], if_any: [name: "foo", state: "new"])
      true
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], if_any: [name: "bar", state: "new"])
      false
      iex> Vex.Validator.validate?([name: "foo", state: "new"], unless: [name: "foo", state: "new"])
      false
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], unless: [name: "foo", state: "new"])
      true
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], unless_any: [name: "foo", state: "new"])
      false
      iex> Vex.Validator.validate?([name: "foo", state: "persisted"], unless_any: [name: "bar", state: "new"])
      true
  """
  def validate?(data, options) when is_list(options) do
    cond do
      Keyword.has_key?(options, :if) -> validate_if(data, Keyword.get(options, :if), :all)
      Keyword.has_key?(options, :if_any) -> validate_if(data, Keyword.get(options, :if_any), :any)
      Keyword.has_key?(options, :unless) -> !validate_if(data, Keyword.get(options, :unless), :all)
      Keyword.has_key?(options, :unless_any) -> !validate_if(data, Keyword.get(options, :unless_any), :any)
      true -> true
    end
  end
  def validate?(_data, _options), do: true

  defp validate_if(data, conditions, opt) when is_list(conditions) do
    case opt do
      :all -> Enum.all?(conditions, &do_validate_if_condition(data, &1))
      :any -> Enum.any?(conditions, &do_validate_if_condition(data, &1))
    end
  end
  defp validate_if(data, condition, _opt) when is_atom(condition) do
    do_validate_if_condition(data, condition)
  end
  defp validate_if(data, condition, _opt) when is_function(condition) do
    !!condition.(data)
  end

  defp do_validate_if_condition(data, {name, value}) when is_atom(name) do
    Vex.Extract.attribute(data, name) == value
  end
  defp do_validate_if_condition(data, condition) when is_atom(condition) do
    !Vex.Blank.blank?(Vex.Extract.attribute(data, condition))
  end

end
