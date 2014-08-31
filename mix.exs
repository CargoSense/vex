defmodule Vex.Mixfile do
  use Mix.Project

  def project do
    [ app: :vex,
      version: "0.4.0",
      elixir: ">= 0.15.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  defp deps do
    deps(Mix.env)
  end

  defp deps(:test) do
    prod_deps ++ test_deps
  end

  defp deps(_) do
    prod_deps
  end

  defp prod_deps do
    []
  end

  defp test_deps do
    [{:ex_unit_emacs, "~> 0.1.0"}]
  end

end
