defprotocol Vex.Validator.Lookup do
  @doc """
  Determines the lookup method of validator modules based on the datastructure at hand.
  Defaults to `Vex.validator/1`.

  `Vex.Struct` types can leverage a more optimized mechanism when initialized by using
  ```
  use Vex.Struct, precompile_validator_lookup: true
  ```
  This performs the validator lookup once, and pushes a lookup data structure into the module at compile time.
  """

  @fallback_to_any true
  def lookup(to_validate, name)
end

defimpl Vex.Validator.Lookup, for: Any do
  def lookup(_to_validate, name) do
    Vex.validator(name)
  end
end
