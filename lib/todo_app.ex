defmodule TodoApp do
  use Application

  def start(_, _) do
    TodoApp.Supervisor.start_link
  end
end
