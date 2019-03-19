defmodule PMBackend.State do
  use Agent
  require Logger
  alias __MODULE__, as: This
  alias PMBackend.Node

  @max_steps 10

  defstruct [
    :hash,
    steps: [],
    version: 0,
    snapshot_version: 0,
    clients: MapSet.new()
  ]

  def start_link({hash, _}) do
    Logger.info("Starting server for hash #{hash}")

    Agent.start_link(fn -> %This{hash: hash} end, name: server(hash))
  end

  def register(hash) do
    pid = self()

    Agent.get_and_update(server(hash), fn this ->
      doc = Node.fetch(this.hash)
      res = %{doc: doc, steps: this.steps, version: this.snapshot_version}
      {res, %This{this | clients: MapSet.put(this.clients, pid)}}
    end)
  end

  def unregister(hash) do
    pid = self()
    Agent.update(server(hash), &%This{&1 | clients: MapSet.delete(&1.clients, pid)})
  end

  def receive(hash, msg) do
    Agent.cast(server(hash), fn this ->
      Logger.debug("receiving....")
      Logger.debug("my version: #{this.version}, client version: #{msg["version"]}")

      if msg["version"] == this.version do
        steps =
          Enum.map(msg["steps"], fn step ->
            {step, msg["clientID"]}
          end)

        Enum.each(this.clients, fn client ->
          send(client, {:steps, steps})
        end)

        new_version = this.version + length(steps)
        new_steps = this.steps ++ steps

        {new_steps, snapshot_version} =
          if length(new_steps) > @max_steps do
            Logger.debug("snapshotting...")
            {steps, client_ids} = Enum.unzip(new_steps)
            Node.snapshot(this.hash, steps, client_ids)
            Logger.debug("snaphshotting complete...")
            {[], new_version}
          else
            Logger.debug("not snapshotting...")
            {new_steps, this.snapshot_version}
          end

        %This{this | steps: new_steps, version: new_version, snapshot_version: snapshot_version}
      else
        Logger.debug("ignoring out of date steps")
        this
      end
    end)
  end

  def dump(hash) do
    Agent.get(server(hash), & &1)
  end

  def reset(hash) do
    Agent.update(server(hash), fn _ -> %This{} end)
  end

  defp server(hash), do: {:via, Registry, {PMBackend.Registry, hash}}
end
