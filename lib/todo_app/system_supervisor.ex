defmodule TodoApp.SystemSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      supervisor(TodoApp.Database, ["./persist/"]),
      supervisor(TodoApp.TodoServerSupervisor, []),
      worker(TodoApp.TodoCache, [])
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
