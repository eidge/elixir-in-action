defmodule TodoApp.TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  @type t :: %__MODULE__{
    auto_id: integer,
    entries: HashDict.t
  }

  alias TodoApp.TodoEntry

  def new, do: %__MODULE__{}
  def new(entries) do
    Enum.reduce(entries, new, &add_entry(&2, &1))
  end

  def entries(%__MODULE__{entries: entries}) do
    Enum.map(entries, fn({_, entry}) -> entry end)
  end
  def entries(%__MODULE__{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->  entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def add_entry(%__MODULE__{} = todo_list, %TodoEntry{} = entry) do
    new_entry   = %TodoEntry{entry | id: todo_list.auto_id}
    new_entries = HashDict.put todo_list.entries, todo_list.auto_id, new_entry
    %__MODULE__{
      auto_id: todo_list.auto_id + 1,
      entries: new_entries}
  end

  def update_entry(%__MODULE__{} = todo_list, entry_id, update_fn) when is_number(entry_id) do
    case todo_list.entries[entry_id] do
      nil -> todo_list
      old_entry ->
        new_entry = %TodoEntry{} = update_fn.(old_entry)
        new_entries = HashDict.put(todo_list.entries, entry_id, new_entry)
        %__MODULE__{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%__MODULE__{} = todo_list, entry_id) when is_number(entry_id) do
    new_entries = HashDict.delete(todo_list.entries, entry_id)
    %__MODULE__{todo_list | entries: new_entries}
  end

  defimpl Collectable, for: __MODULE__ do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(todo_list, :halt), do: :ok
    defp into_callback(todo_list, {:cont, entry}) do
      TodoList.add_entry(todo_list, entry)
    end
  end
end
