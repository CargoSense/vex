defmodule Vex.ErrorRenderer do
  @moduledoc """
  Implementation of this behaviour should be set in validator options as `:error_renderer`
  or in `:vex` application config with same key.

  Common pattern is to expect `:message` key in validator options and if it not set
  use `default_message` (use `get_message` function for it).

  Result of `message` function appears in `Vex.errors` error tuple as last element, for those
  validators who use `Vex.Validator.ErrorMessage` (in general they should).
  ```
  """

  @callback message(validator_options::list(), default_message::String.t, context::list()) :: any()

  def get_message(options, default) do
    if Keyword.keyword?(options) do
      Keyword.get(options, :message, default)
    else
      default
    end
  end
end
