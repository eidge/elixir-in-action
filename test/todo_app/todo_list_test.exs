defmodule TodoApp.TodoListTest do
  use ExUnit.Case

  alias TodoApp.TodoList
  alias TodoApp.TodoEntry

  setup do
    {:ok, new_entry: TodoEntry.new(title: "Make dinner", date: {1992, 2, 4})}
  end

  test "new/0 returns a new %TodoList{}" do
    list = TodoList.new
    assert list == %TodoList{}
    assert TodoList.entries(list) |> length == 0
  end

  test "new/1 returns a new %TodoList{} with entries", %{new_entry: new_entry} do
    entries = [new_entry, new_entry, new_entry]
    list = TodoList.new(entries)
    assert TodoList.entries(list) |> length == 3
  end

  test "entries/2 returns all entries for a given date", %{new_entry: new_entry} do
    another_entry = TodoEntry.new(title: "Make dinner", date: {1992, 2, 5})
    list = TodoList.new
    |> TodoList.add_entry(new_entry)
    |> TodoList.add_entry(new_entry)
    |> TodoList.add_entry(another_entry)

    assert TodoList.entries(list, {1992, 2, 4}) |> length == 2
    assert TodoList.entries(list, {1992, 2, 5}) |> length == 1
    assert TodoList.entries(list, {1992, 2, 6}) |> length == 0
  end

  test "add_entry/2 adds an entry to a given TodoList", %{new_entry: new_entry} do
    list = TodoList.new |> TodoList.add_entry(new_entry)
    assert [%TodoEntry{title: "Make dinner"}] = TodoList.entries(list, {1992, 2, 4})
    assert TodoList.entries(list, {1992, 2, 4}) |> length == 1
  end

  test "add_entry/2 assigns an id to each entry", %{new_entry: new_entry} do
    list = TodoList.new |> TodoList.add_entry(new_entry) |> TodoList.add_entry(new_entry)

    assert TodoList.entries(list, {1992, 2, 4}) |> Enum.find(&(&1.id == 1))
    assert TodoList.entries(list, {1992, 2, 4}) |> Enum.find(&(&1.id == 2))
  end

  test "update_entry/3 updates an existing entry", %{new_entry: new_entry} do
    list = TodoList.new |> TodoList.add_entry(new_entry)
    modified_entry = TodoList.entries(list) |> List.first
    modified_entry = %{modified_entry | title: "I was modified"}

    modified_list = TodoList.update_entry(list, modified_entry.id, fn _ -> modified_entry end)
    modified_list_entry = TodoList.entries(modified_list) |> List.first

    assert modified_list_entry.title == "I was modified"
  end

  test "update_entry/3 does not update list if entry id does not exist",
      %{new_entry: new_entry} do
    list = TodoList.new |> TodoList.add_entry(new_entry)
    modified_entry = TodoList.entries(list) |> List.first
    modified_entry = %{modified_entry | title: "I was modified"}

    modified_list = TodoList.update_entry(list, -1, fn _ -> modified_entry end)

    assert modified_list == list
  end

  test "delete_entry/2 deletes an existing entry",
      %{new_entry: new_entry} do
    list = TodoList.new |> TodoList.add_entry(new_entry)
    entry = list |> TodoList.entries |> List.first
    new_entries = TodoList.delete_entry(list, entry.id) |> TodoList.entries
    assert length(new_entries) == 0
  end

  test "delete_entry/2 returns current list when trying to delete a non existing id",
      %{new_entry: new_entry} do
    list = TodoList.new |> TodoList.add_entry(new_entry)
    entry = list |> TodoList.entries |> List.first
    new_entries = TodoList.delete_entry(list, -1) |> TodoList.entries
    assert length(new_entries) == 1
  end
end
