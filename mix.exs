defmodule Vex.Mixfile do
  use Mix.Project

  def project do
    [ app: :vex,
      version: "0.3.0",
      elixir: ">= 0.15.2-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    []
  end
end
