defmodule SlateOT.Socket do
  @behaviour :cowboy_websocket
  require Logger

  @impl true
  def init(req, state) do
    Logger.error "here!"
    {:cowboy_websocket, req, state}
  end

  @impl true
  def websocket_handle(msg, state) do
    Logger.error inspect msg
    {:ok, state}
  end

  @impl true
  def websocket_info(msg, state) do
    Logger.error inspect msg
    {:ok, state}
  end

end
