defprotocol Vex.Blank do
  @only [Atom, Tuple, List, BitString, Map, Any]
  @doc "Whether an item is blank"
  def blank?(value)
end

defimpl Vex.Blank, for: List do
  def blank?([]), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: Float do
  def blank?(_), do: false
end

defimpl Vex.Blank, for: Integer do
  def blank?(_), do: false
end

defimpl Vex.Blank, for: Tuple do
  def blank?({}), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: BitString do
  def blank?(""), do: true
  def blank?(_),  do: false
end

defimpl Vex.Blank, for: Atom do
  def blank?(nil),   do: true
  def blank?(false), do: true
  def blank?(_),     do: false
end

defimpl Vex.Blank, for: Map do
  def blank?(map), do: map_size(map) == 0
end

defimpl Vex.Blank, for: Any do
  def blank?(_), do: false
end
