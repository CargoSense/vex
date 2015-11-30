defprotocol Vex.Extract do

  @doc "Extract the validation settings"
  def settings(data)

  @doc "Extract an attribute's value"
  def attribute(data, name)

end

defimpl Vex.Extract, for: List do
  def settings(data) do
    Keyword.get data, :_vex
  end

  def attribute(map, path) when is_list(path) do
    get_in map, path
  end
  def attribute(data, name) do
    Keyword.get data, name
  end
end

defimpl Vex.Extract, for: Map do
  def settings(map) do
    Map.get(map, :_vex)
  end
  def attribute(map, name) do
    Map.get(map, name)
  end
end

defmodule Vex.Extract.Struct do
  defmacro for_struct do
    quote do
      defimpl Vex.Blank, for: __MODULE__ do
        def blank?(struct), do: (struct |> Map.from_struct |> map_size) == 0
      end

      defimpl Vex.Extract, for: __MODULE__ do
        def settings(%{__struct__: module}) do
          module.__vex_validations__
        end

        def attribute(map, [root_attr | path]) do
          Map.get(map, root_attr) |> get_in(path)
        end
        def attribute(map, name) do
          Map.get(map, name)
        end
      end
    end
  end
end

defimpl Vex.Extract, for: Tuple do
  def settings(record) do
    [name | _tail] = Tuple.to_list(record)
    record_validations(name)
  end

  def attribute(record, attribute) do
    [name | _tail] = Tuple.to_list(record)
    case record_attribute_index(name, attribute) do
      nil -> nil
      number when is_integer(number) -> elem(record, number)
    end
  end

  defp record_validations(name) do
    try do
      name.__record__(:vex_validations)
    rescue
      _ -> []
    end
  end

  defp record_attribute_index(name, attribute) do
    try do
      name.__record__(:index, attribute)
    rescue
      _ -> nil
    end
  end

end
