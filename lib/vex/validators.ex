defmodule Vex.Validators do

  import Mix.Utils, only: [camelize: 1]

  def validator(name) do
    module = Module.concat(Vex.Validators, camelize(atom_to_binary(name)))
    if function_exported?(module, :validate, 2) do
      module
    else
      raise Vex.InvalidValidatorError, validation: name
    end
  end

  defp validator_submodule(name) do
    name |> atom_to_binary
  |>
    String.split("_") |> Enum.map(&String.capitalize/1)
  |>
    Enum.reduce(&Kernel.<>/2)
  end
  
end