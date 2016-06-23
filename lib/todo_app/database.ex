defmodule TodoApp.Database do
  alias TodoApp.Database.Worker

  @pool_size 3

  def start_link(db_folder) do
    TodoApp.Database.Supervisor.start_link(db_folder, @pool_size)
  end

  def store(key, data) do
    {_results, bad_nodes} = :rpc.multicall(
      __MODULE__,
      :store_local,
      [key, data],
      :timer.seconds(5))

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  def store_local(key, data) do
    worker_id = worker_id_for(key)
    Worker.store(worker_id, key, data)
  end

  def get(key) do
    worker_id = worker_id_for(key)
    Worker.get(worker_id, key)
  end

  defp worker_id_for(key) do
    :erlang.phash2(key, 3) + 1
  end
end
