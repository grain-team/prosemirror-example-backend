defmodule PMBackend.Application do
  @moduledoc false
  require Logger

  use Application

  def start(_type, _args) do
    children = [
      PMBackend.Node,
      {Registry, name: PMBackend.Registry, keys: :unique},
      PMBackend.StateSupervisor
    ]

    dispatch = :cowboy_router.compile([{:_, [{'/', PMBackend.Socket, []}]}])

    {:ok, _} =
      :cowboy.start_clear(:pm_backend, [port: 8080], %{
        env: %{dispatch: dispatch}
      })

    case Code.ensure_loaded(ExSync) do
      {:module, ExSync = mod} ->
        mod.start()

      {:error, :nofile} ->
        :ok
    end

    opts = [strategy: :rest_for_one, name: PMBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
