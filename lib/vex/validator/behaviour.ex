defmodule Vex.Validator.Behaviour do
  use Behaviour

  defcallback validate(data :: any, options :: any) :: atom | {atom, String.t}

  defcallback validate(data :: any, context :: any, options :: any) :: atom | {atom, String.t}

end