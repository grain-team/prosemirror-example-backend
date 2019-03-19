defmodule PMBackend.StateSupervisor do
  use DynamicSupervisor
  alias __MODULE__, as: This

  def start_child(hash, opts \\ []) do
    DynamicSupervisor.start_child(This, {PMBackend.State, {hash, opts}})
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child(This, pid)
  end

  def start_link(arg) do
    DynamicSupervisor.start_link(This, arg, name: This)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
