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
    {steps, client_ids} = State.register() |> Enum.unzip()
    reply(%{type: "init", steps: Enum.reverse(steps), clientIDs: client_ids}, state)
  end

  @impl true
  def websocket_handle({:text, msg}, state) do
    msg = Jason.decode!(msg)
    State.receive(msg)
    {:ok, state}
  end

  @impl true
  def websocket_info({:steps, steps}, state) do
    {steps, client_ids} = Enum.unzip(steps)
    reply(%{type: "steps", steps: steps, clientIDs: client_ids}, state)
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
