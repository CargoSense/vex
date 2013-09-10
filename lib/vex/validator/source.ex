defprotocol Vex.Validator.Source do
  
  def lookup(source, name)

end

defimpl Vex.Validator.Source, for: Atom do

  def lookup(module, name) do
    apply(module, :validator, [name])
  end

end

defimpl Vex.Validator.Source, for: List do

  def lookup(list, name) do
    Keyword.get(list, name)
  end

end