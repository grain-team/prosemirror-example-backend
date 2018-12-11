defmodule SlateOT.MixProject do
  use Mix.Project

  def project do
    [
      app: :slate_ot,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SlateOT.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.6"}
    ]
  end
end
