defmodule Vex.Mixfile do
  use Mix.Project

  @source_url "https://github.com/CargoSense/vex"
  @version "0.8.0"

  def project do
    [
      app: :vex,
      version: "0.8.0",
      elixir: "~> 1.6",
      name: "Vex",
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:eex]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      contributors: ["Bruce Williams", "Ben Wilson", "John Hyland"],
      maintainers: ["Bruce Williams", "Ben Wilson", "John Hyland"],
      licenses: ["MIT License"],
      description: "An extensible data validation library for Elixir",
      links: %{GitHub: @source_url}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      homepage_url: "https://github.com/CargoSense/vex",
      source_url: "https://github.com/CargoSense/vex",
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
