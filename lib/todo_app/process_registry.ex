defmodule TodoApp.ProcessRegistry do
  import Kernel, except: [send: 2]

  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    IO.puts "Starting ProcessRegistry"
    {:ok, HashDict.new}
  end

  def register_name(key, pid) do
    GenServer.call(__MODULE__, {:register_name, key, pid})
  end

  def whereis_name(key) do
    GenServer.call(__MODULE__, {:whereis_name, key})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def handle_call({:register_name, key, pid}, _, process_registry) do
    case HashDict.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, HashDict.put(process_registry, key, pid)}
      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _, process_registry) do
    {:reply, HashDict.get(process_registry, key, :undefined), process_registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    pid_key = find_key_from_pid(process_registry, pid)
    {:noreply, HashDict.delete(process_registry, pid_key)}
  end

  defp find_key_from_pid(process_registry, pid) do
    {key, _} = Enum.find(process_registry, fn({_, pid_in_registry}) ->
      pid_in_registry == pid
    end)
    key
  end
end
