defmodule TodoApp.Database do
  use GenServer

  alias TodoApp.Database.Worker

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :db_server)
  end

  def init(db_folder) do
    ensure_directory_exists(db_folder)
    workers = start_workers(db_folder)
    {:ok, {db_folder, workers}}
  end

  defp ensure_directory_exists(db_folder) do
    :ok = File.mkdir_p(db_folder)
  end

  defp start_workers(db_folder) do
    Enum.reduce(1..3, %{}, fn i, workers ->
      {:ok, worker} = Worker.start(db_folder)
      Map.put(workers, i, worker)
    end)
  end

  def store(key, data) do
    GenServer.cast(:db_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:db_server, {:get, key})
  end

  # Server callbacks

  def handle_cast({:store, key, data}, {_, workers} = state) do
    workers
    |> worker_for(key)
    |> Worker.store(key, data)
    {:noreply, state}
  end

  def handle_call({:get, key}, caller, {_, workers} = state) do
    workers
    |> worker_for(key)
    |> Worker.get(caller, key)
    {:noreply, state}
  end

  defp worker_for(workers, key) do
    Map.fetch!(workers, :erlang.phash2(key, 3))
  end
end
