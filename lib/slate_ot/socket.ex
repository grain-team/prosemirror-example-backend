defmodule SlateOT.Socket do
  @behaviour :cowboy_websocket
  require Logger
  alias SlateOT.State

  @impl true
  def init(req, state) do
    Logger.info("Connection establish")
    {:cowboy_websocket, req, state}
  end

  @impl true
  def websocket_init(state) do
    operations = State.register()
    reply(%{type: "init", operations: operations}, state)
  end

  @impl true
  def websocket_handle(msg, state) do
    Logger.error(inspect(msg))
    {:ok, state}
  end

  @impl true
  def websocket_info(msg, state) do
    Logger.error(inspect(msg))
    {:ok, state}
  end

  @impl true
  def terminate(_, _, _) do
    State.unregister()
    :ok
  end

  defp reply(msg, state) do
    {:reply, {:text, Jason.encode!(msg)}, state}
  end
end
