defprotocol Vex.Validator.Source do

  def lookup(source, name)

end

defimpl Vex.Validator.Source, for: Atom do

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

  # Backported from Elixir's `Macro.camelize`
  @spec camelize(String.t) :: String.t
  defp camelize(string)

  defp camelize(""),
    do: ""

  defp camelize(<<?_, t::binary>>),
    do: camelize(t)

  defp camelize(<<h, t::binary>>),
    do: <<to_upper_char(h)>> <> do_camelize(t)

  defp do_camelize(<<?_, ?_, t::binary>>),
    do: do_camelize(<<?_, t::binary >>)

  defp do_camelize(<<?_, h, t::binary>>) when h >= ?a and h <= ?z,
    do: <<to_upper_char(h)>> <> do_camelize(t)

  defp do_camelize(<<?_>>),
    do: <<>>

  defp do_camelize(<<?/, t::binary>>),
    do: <<?.>> <> camelize(t)

  defp do_camelize(<<h, t::binary>>),
    do: <<h>> <> do_camelize(t)

  defp do_camelize(<<>>),
    do: <<>>

  defp to_upper_char(char) when char >= ?a and char <= ?z, do: char - 32
  defp to_upper_char(char), do: char

end

defimpl Vex.Validator.Source, for: List do

  def lookup(list, name) do
    Keyword.get(list, name)
  end

end
