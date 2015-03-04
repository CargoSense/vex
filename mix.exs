defmodule Vex.Mixfile do
  use Mix.Project

  def project do
    [ app: :vex,
      version: "0.5.1",
      elixir: ">= 0.15.1",
      deps: deps,
      package: package ]
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
    []
  end

  defp package do
    [contributors: ["Bruce Williams", "Ben Wilson"],
     licenses: ["MIT License"],
     description: "An extensible data validation library for Elixir",
     links: %{github: "https://github.com/CargoSense/vex"}]
  end

end
