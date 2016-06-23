defmodule TodoApp.TodoCache do
  alias TodoApp.TodoServer
  alias TodoApp.TodoServerSupervisor

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def init(_) do
    IO.puts "Starting TodoCache"
    {:ok, nil}
  end

  def server_process(todo_list_name) do
    case TodoServer.whereis(todo_list_name) do
      :undefined -> start_todo_server(todo_list_name)
      pid -> pid
    end
  end

  defp start_todo_server(todo_list_name) do
    case TodoServerSupervisor.start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
