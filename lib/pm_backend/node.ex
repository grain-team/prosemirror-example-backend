defmodule PMBackend.Node do
  use GenServer

  alias __MODULE__, as: This

  @server_path Path.expand("priv/js/index.js", elem(File.cwd(), 1))
  # Expected Errors
  _ = [:unknown_command]

  def fetch(hash) do
    {:ok, [doc]} = GenServer.call(This, {:fetch, hash})
    doc
  end

  def snapshot(hash, steps, client_ids) do
    {:ok, []} = GenServer.call(This, {:snapshot, hash, steps, client_ids})
    :ok
  end

  def start_link(_) do
    GenServer.start_link(This, [], name: This)
  end

  @impl true
  def init(_) do
    server_options = %{stdin: true, stdout: true, stderr: true}
    {:ok, server_pid, server_os_pid} = Exexec.run_link("node #{@server_path}", server_options)
    {:ok, {server_pid, server_os_pid}}
  end

  @impl true
  def handle_call({:fetch, hash}, _, state) do
    call([:fetch, hash, %{}], state)
  end

  def handle_call({:snapshot, hash, steps, client_ids}, _, state) do
    call([:snapshot, hash, %{steps: steps, clientIds: client_ids}], state)
  end

  defp call(params, state = {server_pid, server_os_pid}) do
    Exexec.send(server_pid, Jason.encode!(params) <> "\n")

    receive do
      {:stdout, ^server_os_pid, res} ->
        case Jason.decode!(res) do
          ["OK" | res] -> {:reply, {:ok, res}, state}
          ["ERROR", error] -> {:reply, {:error, format_error(error)}, state}
        end
    end
  end

  defp format_error(message) do
    message
    |> String.trim()
    |> String.to_existing_atom()
  end
end
