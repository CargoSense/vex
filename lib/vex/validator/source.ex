defprotocol Vex.Validator.Source do

  def lookup(source, name)

end

defimpl Vex.Validator.Source, for: Atom do

  import Macro, only: [camelize: 1]

  def lookup(source, name) do
    validator_by_function(source, name) || validator_by_structure(source, name)
  end

  defp validator_by_function(source, name) do
    Code.ensure_loaded(source)
    if function_exported?(source, :validator, 1) do
      check source.validator(name)
    end
  end

  defp validator_by_structure(source, name) do
    check Module.concat(source, camelize(Atom.to_string(name)))
  end

  defp check(validator) do
    Code.ensure_loaded(validator)
    if function_exported?(validator, :validate, 2) do
      validator
    end
  end

end

defimpl Vex.Validator.Source, for: List do

  def lookup(list, name) do
    Keyword.get(list, name)
  end

end
