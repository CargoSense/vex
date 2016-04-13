defmodule Vex.Validator.ErrorMessage do

  defmacro __using__(_) do
    quote do
      @message_fields []
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def __validator__(:message_fields), do: @message_fields
    end
  end

  @doc """
  Extract the error message from validator options or return a default

  ## Examples

      iex> Vex.Validator.ErrorMessage.message(nil, "default")
      "default"
      iex> Vex.Validator.ErrorMessage.message([message: "override"], "default")
      "override"
      iex> Vex.Validator.ErrorMessage.message([message: "Context #<%= value %>"], "default", value: 2)
      "Context #2"
  """
  def message(options, default) do
    if Keyword.keyword?(options) do
      Keyword.get(options, :message, default)
    else
      default
    end
  end
  def message(options, default, context) do
    message_text = message(options, default)
    if Keyword.keyword?(options) && options[:eex] == false do
      [text: message_text, vars: extract_vars(context)]
    else
      EEx.eval_string(message_text, context)
    end
  end

  defp extract_vars(context) do
    Enum.filter context, fn({key, value}) -> is_boolean(value) || is_number(value) || is_binary(value) || is_nil(value) end
  end
end
