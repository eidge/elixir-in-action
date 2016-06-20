defmodule TodoApp.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      worker(TodoApp.ProcessRegistry, []),
      supervisor(TodoApp.SystemSupervisor, []),
    ]
    supervise(processes, strategy: :rest_for_one)
  end
end
