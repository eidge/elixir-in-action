defmodule TodoApp.TodoServer do
  use GenServer

  alias TodoApp.{TodoList, Database}

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:todo_server, name}}}
  end

  def whereis(name) do
    :gproc.whereis_name({:n, :l, {:todo_server, name}})
  end

  def init(name) do
    IO.puts "Starting TodoServer #{name}"
    todo_list = Database.get(name) || TodoList.new
    {:ok, {name, todo_list}}
  end

  def entries(pid) do
    GenServer.call(pid, :entries)
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def update_entry(pid, id, update_fn) do
    GenServer.cast(pid, {:update_entry, id, update_fn})
  end

  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  # Server Callbacks

  def handle_call(:entries, _, {name, todo_list}) do
    {:reply, TodoList.entries(todo_list), {name, todo_list}}
  end

  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_list = TodoList.add_entry(todo_list, entry)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_cast({:update_entry, id, update_fn}, {name, todo_list}) do
    new_list = TodoList.update_entry(todo_list, id, update_fn)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_list = TodoList.delete_entry(todo_list, id)
    Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end
end
