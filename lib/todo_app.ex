defmodule TodoApp do
  use Application

  def start(_, _) do
    application = TodoApp.Supervisor.start_link
    TodoApp.Web.start_server
    application
  end
end
