defmodule Vex.ErrorRenderer do
  @moduledoc """

  """

  @callback message(options::keyword(), default::String.t, context::keyword()) :: any()

  def get_message(options, default) do
    if Keyword.keyword?(options) do
      Keyword.get(options, :message, default)
    else
      default
    end
  end
end
