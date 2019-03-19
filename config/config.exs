# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
  backends: [:console],
  level: :info

config :logger, :console,
  format: "\n$time $metadata[$level] $levelpad$message\n",
  metadata: [:pid]
