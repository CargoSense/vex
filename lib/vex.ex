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
    Enum.filter results(data, settings), match?({:error, _, _}, &1)
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
        try do
         case result(data, attribute, name, options) do
            true  -> {:ok, attribute, name}
            false -> {:error, attribute, name}
            nil   -> {:error, attribute, name}
            _     -> {:ok, attribute, name}
          end
        rescue
          err -> IO.inspect(err); {:error, attribute, name}
        end
      end)
    end)
  |>
    List.flatten
  end

  defp result(data, attribute, :confirmation, options) do
    Enum.map([attribute, binary_to_atom("#{attribute}_confirmation")], fn (attr) ->
      Vex.Extract.attribute(data, attr)
    end)
  |>
    validator(:confirmation, options)
  end

  defp result(data, attribute, name, options) do
    Vex.Extract.attribute(data, attribute)
  |>
    validator(name, options)
  end

  defp validator(value, name, options) do
    apply(Vex.Validators, name, [value, options])
  end

end