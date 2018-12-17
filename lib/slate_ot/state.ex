defmodule SlateOT.State do
  use Agent
  alias __MODULE__, as: This

  defstruct(
    operations: [],
    clients: MapSet.new()
  )

  def start_link(_) do
    Agent.start_link(fn -> %This{} end, name: This)
  end

  def register() do
    pid = self()
    Agent.get_and_update(This, fn this ->
      {this.operations, %This{this | clients: MapSet.put(this.clients, pid)}}
    end)
  end

  def unregister() do
    pid = self()
    Agent.update(This, &%This{&1 | clients: MapSet.delete(&1.clients, pid)})
  end

  def dump() do
    Agent.get(This, & &1)
  end

  def reset() do
    Agent.update(This, fn _ -> %This{} end)
  end
end
