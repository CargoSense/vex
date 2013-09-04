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
  def attribute(data, name) do
    Keyword.get data, name
  end
end

defimpl Vex.Extract, for: Tuple do
  def settings(record) do
    [name | tail] = tuple_to_list(record)
    record_validations(name)
  end
  def attribute(record, attribute) do
    [name | tail] = tuple_to_list(record)
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
