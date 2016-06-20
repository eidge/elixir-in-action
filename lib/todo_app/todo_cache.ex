defmodule TodoApp.TodoCache do
  use GenServer

  alias TodoApp.TodoServer
  alias TodoApp.TodoServerSupervisor

  def start do
    GenServer.start(__MODULE__, nil, name: :todo_cache)
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :todo_cache)
  end

  def init(_) do
    IO.puts "Starting TodoCache"
    {:ok, nil}
  end

  def server_process(todo_list_name) do
    case TodoServer.whereis(todo_list_name) do
      :undefined -> GenServer.call(:todo_cache, {:server_process, todo_list_name})
      pid -> pid
    end
  end

  def handle_call({:server_process, todo_list_name}, _, _) do
    case TodoServer.whereis(todo_list_name) do
      :undefined ->
        {:ok, new_server} = TodoServerSupervisor.start_child(todo_list_name)
        {:reply, new_server, nil}
      server ->
        {:reply, server, nil}
    end
  end
end
