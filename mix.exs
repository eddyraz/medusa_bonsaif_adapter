defmodule MedusaBonsaifAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :medusa_bonsaif_adapter,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MedusaBonsaifAdapter.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpotion, "~> 3.1.0"},
      {:jason, "~> 1.2"}
    ]
  end
end
