defmodule AuthN.MixProject do
  use Mix.Project

  @version "0.22.0"

  def project do
    [
      app: :auth_n,
      elixir: "~> 1.9",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Hex
      version: @version,
      package: package(),
      description: "Authentication library for Elixir applications",

      # ExDoc
      name: "AuthN",
      source_url: "https://github.com/mathieuprog/auth_n",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_html, "~> 3.2", optional: true},
      {:plug, "~> 1.12", optional: true},
      {:phoenix, "~> 1.6", optional: true},
      {:ex_doc, "~> 0.26", only: :dev},
      {:inch_ex, "~> 2.0", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Mathieu Decaffmeyer"],
      links: %{"GitHub" => "https://github.com/mathieuprog/auth_n"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end
