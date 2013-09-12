defmodule Vex do

  def valid?(data) do
    valid?(data, Vex.Extract.settings(data))
  end
  def valid?(data, settings) do
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
    v = validator(name)
    if Vex.Validator.validate?(data, options) do
      result = extract(data, attribute, name) |> v.validate(options)
      case result do
        {:error, message} -> {:error, attribute, name, message}
        :ok -> {:ok, attribute, name}
        _ -> raise "'#{name}'' validator should return :ok or {:error, message}"
      end
    else
      {:not_applicable, attribute, name}
    end
  end

  @doc """
  Lookup a validator from configured sources

  ## Examples

    iex> Vex.validator(:presence)
    Vex.Validators.Presence
    iex> Vex.validator(:exclusion)
    Vex.Validators.Exclusion    
  """
  def validator(name) do
    case name |> validator(sources) do
      nil -> raise Vex.InvalidValidatorError, validator: name, sources: sources
      found -> found
    end
  end

  @doc """
  Lookup a validator from given sources

  ## Examples

    iex> Vex.validator(:presence, [[presence: :presence_stub]])
    :presence_stub
    iex> Vex.validator(:exclusion, [Vex.Validators])
    Vex.Validators.Exclusion
    iex> Vex.validator(:presence, [Vex.Validators, [presence: :presence_stub]])
    Vex.Validators.Presence
    iex> Vex.validator(:presence, [[presence: :presence_stub], Vex.Validators])
    :presence_stub        
  """
  def validator(name, sources) do
    Enum.find_value sources, fn (source) -> 
      Vex.Validator.Source.lookup(source, name)
    end
  end

  defp sources do
    Mix.project |> Keyword.get(:vex, []) |> Keyword.get(:sources, [Vex.Validators])
  end

  defp extract(data, attribute, :confirmation) do
    [attribute, binary_to_atom("#{attribute}_confirmation")]
  |>
    Enum.map(fn (attr) -> Vex.Extract.attribute(data, attr) end)
  end
  defp extract(data, attribute, _name) do
    Vex.Extract.attribute(data, attribute)
  end

end
