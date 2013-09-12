defmodule Vex.Validator do
  @moduledoc """
  Common validator behavior.
  """

  defmacro __using__(_) do
    quote do
      import Vex.Validator.Skipping
      use Vex.Validator.ErrorMessage
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
  """
  def validate?(data, options) when is_list(options) do
    cond do
      Keyword.has_key?(options, :if) -> validate_if(data, Keyword.get(options, :if))
      Keyword.has_key?(options, :unless) -> !validate_if(data, Keyword.get(options, :unless))
      true -> true
    end
  end
  def validate?(data, options), do: true

  defp validate_if(data, conditions) when is_list(conditions) do
    Enum.all?(conditions, do_validate_if_condition(data, &1))
  end
  defp validate_if(data, condition) when is_atom(condition) do
    do_validate_if_condition(data, condition)
  end
  defp validate_if(data, condition) when is_function(condition) do
    !!condition.(data)
  end  

  defp do_validate_if_condition(data, {name, value}) when is_atom(name) do
    Vex.Extract.attribute(data, name) == value
  end  
  defp do_validate_if_condition(data, condition) when is_atom(condition) do
    !Vex.Blank.blank?(Vex.Extract.attribute(data, condition))
  end

end