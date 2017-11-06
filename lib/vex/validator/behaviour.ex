defmodule Vex.Validator.Behaviour do
  @callback validate(data :: any, options :: any) :: atom | {atom, String.t}
  @callback validate(data :: any, context :: any, options :: any) :: atom | {atom, String.t}
end
