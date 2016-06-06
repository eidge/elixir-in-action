defmodule TodoApp.TodoServer do
  use GenServer

  alias TodoApp.TodoList

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, TodoList.new}
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

  def handle_call(:entries, _, todo_list) do
    {:reply, TodoList.entries(todo_list), todo_list}
  end

  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end

  def handle_cast({:update_entry, id, update_fn}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, id, update_fn)}
  end

  def handle_cast({:delete_entry, id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, id)}
  end
end
