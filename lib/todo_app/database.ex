defmodule TodoApp.Database do
  alias TodoApp.Database.Worker

  @pool_size 3

  def start_link(db_folder) do
    TodoApp.Database.Supervisor.start_link(db_folder, @pool_size)
  end

  def init(db_folder) do
    IO.puts("Starting Database")
    ensure_directory_exists(db_folder)
    :ok
  end

  defp ensure_directory_exists(db_folder) do
    :ok = File.mkdir_p(db_folder)
  end

  def store(key, data) do
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
