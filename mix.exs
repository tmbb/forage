defmodule Forage.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :forage,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.10"},
      {:json, ">= 0.0.0"},
      {:paginator, "~> 1.0"},
      {:ex_doc, "~> 0.23", only: :dev}
    ]
  end

  defp description() do
    "Dynamic ecto query builder"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "forage",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tmbb/forage"}
    ]
  end

  defp aliases() do
    [
      publish: "run scripts/publish.exs"
    ]
  end
end
