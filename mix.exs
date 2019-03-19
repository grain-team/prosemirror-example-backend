defmodule PMBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :pm_backend,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :erlexec, :exexec],
      mod: {PMBackend.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.6"},
      {:jason, "~> 1.1"},
      {:exsync, "~> 0.2.3"},
      {:exexec, github: "lessless/exexec"}
    ]
  end
end
