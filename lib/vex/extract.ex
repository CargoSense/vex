defprotocol Vex.Extract do
  def settings(data)
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