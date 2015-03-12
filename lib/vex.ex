defmodule Vex do

  @typep attribute    :: atom
  @typep name         :: atom
  @typep error_result :: {:error, attribute, name, term}
  @typep ok_result    :: {:ok, attribute, name}


  @doc """
  Return `:ok` or an error tuple with the list of errors.

  ## Examples

      iex> Vex.validate([name: "Foo"], name: [presence: true])
      :ok

      iex> Vex.validate([name: "Foo"], name: [absence: true])
      {:error, [{:name, :absence, "must be absent"}]}
  """
  @spec validate(term, Keyword.t) :: :ok | {:error, [{attribute, name, term}]}
  def validate(data) do
    validate(data, Vex.Extract.settings(data))
  end
  def validate(data, settings) do
    case errors(data, settings) do
      [] ->
        :ok
      errors when is_list(errors) ->
        {:error, (for {:error, a, n, m} <- errors, do: {a, n, m})}
    end
  end

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
    Enum.filter results(data, settings), &match?({:error, _, _, _}, &1)
  end

  def results(data) do
    results(data, Vex.Extract.settings(data))
  end
  def results(data, settings) do
    for {attribute, vs} <- settings do
      result({data, attribute}, (if is_function(vs), do: [by: vs], else: vs))
    end
    |> List.flatten
  end

  @doc """
  Return the result of apply the validations to the data.

  ## Examples

      iex> Vex.result("Foo", length: [min: 2, max: 10])
      [{:ok, nil, :length}]

      iex> Vex.result("Foo", length: [min: 4, max: 10])
      [{:error, nil, :length, "must have a length between 4 and 10"}]
  """
  @spec result(term, Keyword.t) :: [ok_result | error_result]
  def result(data, func) when is_function(func) do
    result(data, [by: func])
  end
  def result(data, validations) do
    for {name, options} <- validations do
      result(data, name, options)
    end
  end

  @doc false
  @spec result(term, name, Keyword.t) :: ok_result | error_result
  defp result({data, attribute}, name, options) do
    if Vex.Validator.validate?(data, options) do
      result({data, attribute, extract(data, attribute, name)}, name, options)
    else
      {:not_applicable, attribute, name}
    end
  end
  defp result({_, attribute, value}, name, options) do
    case validator(name).validate(value, options) do
      {:error, message} -> {:error, attribute, name, message}
      :ok -> {:ok, attribute, name}
      _ -> raise "'#{name}'' validator should return :ok or {:error, message}"
    end
  end
  defp result(value, name, options) do
    result({nil, nil, value}, name, options)
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
    case Application.get_env(:vex, :sources) do
      nil     -> [Vex.Validators]
      sources -> sources
    end
  end

  defp extract(data, attribute, :confirmation) do
    [attribute, String.to_atom("#{attribute}_confirmation")]
      |> Enum.map(fn (attr) -> Vex.Extract.attribute(data, attr) end)
  end
  defp extract(data, attribute, _name) do
    Vex.Extract.attribute(data, attribute)
  end

end
