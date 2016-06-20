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
    {:ok, nil}
  end

  def register_name(key, pid) do
    GenServer.call(__MODULE__, {:register_name, key, pid})
  end

  def whereis_name(key) do
    case lookup(key) do
      [{^key, pid}] -> pid
      [] -> :undefined
    end
  end

  defp lookup(key) do
    :ets.lookup(__MODULE__, key)
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def handle_call({:register_name, key, pid}, _, nil) do
    case whereis_name(key) do
      :undefined ->
        Process.monitor(pid)
        insert(key, pid)
        {:reply, :yes, nil}
      _ ->
        {:reply, :no, nil}
    end
  end

  defp insert(key, pid) do
    :ets.insert(__MODULE__, {key, pid})
  end

  def handle_info({:DOWN, _, :process, pid, _}, nil) do
    delete_pid(pid)
    {:noreply, nil}
  end

  defp delete_pid(pid) do
    :ets.match_delete(__MODULE__, {:_, pid})
  end
end
