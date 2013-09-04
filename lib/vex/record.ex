defmodule Vex.Record do

  defmacro __using__(_) do
    quote do
      @vex_validations []
      @before_compile unquote(__MODULE__)
      import unquote(__MODULE__)
      def is_valid?(self), do: Vex.is_valid?(self)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def __record__(:vex_validations), do: @vex_validations
    end
  end

  defmacro validates(name, validators // []) do
    quote do
      @vex_validations Keyword.put(@vex_validations, unquote(name), unquote(validators))
    end
  end

end