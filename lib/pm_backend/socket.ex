defmodule PMBackend.Socket do
  @behaviour :cowboy_websocket
  require Logger
  alias PMBackend.State

  @impl true
  def init(req, _state) do
    Logger.info("Connection establish")
    [{"hash", hash}] = :cowboy_req.parse_qs(req)
    {:cowboy_websocket, req, %{hash: hash}, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(state) do
    PMBackend.StateSupervisor.start_child(state.hash)
    %{doc: doc, steps: steps, version: version} = State.register(state.hash)
    {steps, client_ids} = Enum.unzip(steps)
    reply(%{type: "init", steps: steps, clientIDs: client_ids, doc: doc, version: version}, state)
  end

  @impl true
  def websocket_handle({:text, msg}, state) do
    msg = Jason.decode!(msg)
    State.receive(state.hash, msg)
    {:ok, state}
  end

  @impl true
  def websocket_info({:steps, steps}, state) do
    {steps, client_ids} = Enum.unzip(steps)
    reply(%{type: "steps", steps: steps, clientIDs: client_ids}, state)
  end

  @impl true
  def terminate(reason, _, state) do
    Logger.info("terminating, reason: #{inspect(reason)}")

    State.unregister(state.hash)
    :ok
  end

  defp reply(msg, state) do
    {:reply, {:text, Jason.encode!(msg)}, state}
  end
end
