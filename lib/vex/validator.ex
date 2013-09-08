defmodule Vex.Validator do
  @moduledoc """
  Common validator behavior.
  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      import Vex.Validator.Skipping
    end
  end

end