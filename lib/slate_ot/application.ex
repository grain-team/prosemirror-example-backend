defmodule SlateOT.Application do
  @moduledoc false
  require Logger

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: SlateOT.Worker.start_link(arg)
      # {SlateOT.Worker, arg},
    ]

    dispatch = :cowboy_router.compile([{:_, [{'/', SlateOT.Socket, []}]}])
    {:ok, _} = :cowboy.start_clear(:slate_ot, [port: 8080], %{
      env: %{dispatch: dispatch}
    })

    opts = [strategy: :one_for_one, name: SlateOT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
