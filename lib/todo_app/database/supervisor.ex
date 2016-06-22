defmodule TodoApp.Database.Supervisor do
  use Supervisor

  def start_link(db_folder, pool_size) do
    Supervisor.start_link(__MODULE__, {db_folder, pool_size})
  end

  def init({db_folder, pool_size}) do
    ensure_directory_exists(db_folder)
    processes = for worker_id <- 1..pool_size do
      worker(
        TodoApp.Database.Worker,
        [db_folder, worker_id],
        id: {:db_worker, worker_id})
    end
    supervise(processes, strategy: :one_for_one)
  end

  defp ensure_directory_exists(db_folder) do
    :ok = File.mkdir_p(db_folder)
  end
end
