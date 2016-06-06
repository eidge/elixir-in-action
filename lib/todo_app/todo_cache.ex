defmodule TodoApp.TodoCache do
  use GenServer

  alias TodoApp.TodoServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def init(_) do
    TodoApp.Database.start("./persist/") # FIXME
    {:ok, HashDict.new}
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case HashDict.fetch(todo_servers, todo_list_name) do
      {:ok, server} ->
        {:reply, server, todo_servers}
      :error ->
        {:ok, new_server} = TodoServer.start
        {:reply, new_server, HashDict.put(todo_servers, todo_list_name, new_server)}
    end
  end
end
