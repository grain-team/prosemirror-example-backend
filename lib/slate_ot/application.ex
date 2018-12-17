defmodule SlateOT.Application do
  @moduledoc false
  require Logger

  use Application

  def start(_type, _args) do
    children = [
      SlateOT.State
    ]

    dispatch = :cowboy_router.compile([{:_, [{'/', SlateOT.Socket, []}]}])

    {:ok, _} =
      :cowboy.start_clear(:slate_ot, [port: 8080], %{
        env: %{dispatch: dispatch}
      })

    case Code.ensure_loaded(ExSync) do
      {:module, ExSync = mod} ->
        mod.start()

      {:error, :nofile} ->
        :ok
    end

    opts = [strategy: :one_for_one, name: SlateOT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
