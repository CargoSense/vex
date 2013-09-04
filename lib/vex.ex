defmodule Vex do

  def is_valid?(data) do
    is_valid?(data, Vex.Extract.settings(data))
  end
  def is_valid?(data, settings) do
    settings = find_settings(data, settings)
    Enum.all? results(data, settings), fn (result) ->
      case result do
        {:ok, _, _} -> true
        _ -> false
      end
    end
  end

  defp results(data, settings) do
    Enum.map(settings, fn ({attribute, validations}) ->
      if is_function(validations) do
        validations = [validated_by: validations]
      end
      Enum.map(validations, fn ({name, options}) ->
        try do
         case result(data, attribute, name, options) do
            true ->  {:ok, attribute, name}
            false -> {:failed, attribute, name}
            nil   -> {:failed, attribute, name}
            _ -> {:ok, attribute, name}
          end
        catch
          err -> {:error, attribute, name, err}
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
    Vex.Validations.validate(:confirmation, options)
  end

  defp result(data, attribute, name, options) do
    Vex.Extract.attribute(data, attribute)
  |>
    Vex.Validations.validate(name, options)
  end

end