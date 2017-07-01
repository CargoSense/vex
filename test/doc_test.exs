defmodule DocTest do
  use ExUnit.Case
  # Main
  doctest Vex
  doctest Vex.Validator
  # Validator Utilities
  doctest Vex.Validator.ErrorMessage
  doctest Vex.Validator.Skipping
  # Built-in Validators
  doctest Vex.Validators.Absence
  doctest Vex.Validators.Acceptance
  doctest Vex.Validators.By
  doctest Vex.Validators.Confirmation
  doctest Vex.Validators.Exclusion
  doctest Vex.Validators.Format
  doctest Vex.Validators.Inclusion
  doctest Vex.Validators.Length
  doctest Vex.Validators.Presence
  # Built-in ErrorRenderers
  doctest Vex.ErrorRenderers.EEx
  doctest Vex.ErrorRenderers.Parameterized
end
