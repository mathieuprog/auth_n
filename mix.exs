defmodule AuthN.MixProject do
  use Mix.Project

  @version "0.11.0"

  def project do
    [
      app: :auth_n,
      elixir: "~> 1.9",
      deps: deps(),
      aliases: aliases(),
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
      {:argon2_elixir, "~> 2.0", optional: true},
      {:ecto, "~> 3.2", optional: true},
      {:phoenix_html, "~> 2.13", optional: true},
      {:plug, "~> 1.8.3 or ~> 1.9", optional: true},
      {:ex_doc, "~> 0.21", only: :dev},
      {:inch_ex, "~> 2.0", only: :dev},
      {:dialyxir, "~> 0.5", only: :dev},
      {:ecto_sql, "~> 3.2", only: :test},
      {:postgrex, "~> 0.14", only: :test},
      {:ex_machina, "~> 2.3", only: :test}
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

  defp aliases do
    [
      test: [
        "ecto.create --quiet",
        "ecto.rollback --all",
        "ecto.migrate",
        "test"
      ]
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
