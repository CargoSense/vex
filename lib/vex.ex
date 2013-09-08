defmodule Vex do

  def is_valid?(data) do
    is_valid?(data, Vex.Extract.settings(data))
  end
  def is_valid?(data, settings) do
    errors(data, settings) |> length == 0
  end

  def errors(data) do
    errors(data, Vex.Extract.settings(data))
  end
  def errors(data, settings) do
    Enum.filter results(data, settings), match?({:error, _, _, _}, &1)
  end

  def results(data) do
    results(data, Vex.Extract.settings(data))
  end
  def results(data, settings) do
    Enum.map(settings, fn ({attribute, validations}) ->
      if is_function(validations) do
        validations = [by: validations]
      end
      Enum.map(validations, fn ({name, options}) ->
        result(data, attribute, name, options)
      end)
    end)
  |>
    List.flatten
  end

  defp result(data, attribute, name, options) do
    result = extract(data, attribute, name) |> validator(name).validate(options)
    case result do
      {:error, message} -> {:error, attribute, name, message}
      :ok -> {:ok, attribute, name}
      _ -> raise "'#{name}'' validator should return :ok or {:error, message}"
    end
  end

  defp extract(data, attribute, :confirmation) do
    [attribute, binary_to_atom("#{attribute}_confirmation")]
  |>
    Enum.map(fn (attr) -> Vex.Extract.attribute(data, attr) end)
  end
  defp extract(data, attribute, name) do
    Vex.Extract.attribute(data, attribute)
  end

  defp validator(name) do
    module = Module.concat(Vex.Validators, validator_submodule(name))
    if function_exported?(module, :validate, 2) do
      module
    else
      raise Vex.InvalidValidationTypeError, validation: name
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