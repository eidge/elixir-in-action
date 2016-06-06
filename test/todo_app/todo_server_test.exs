defmodule TodoApp.TodoServerTest do
  use ExUnit.Case

  alias TodoApp.{TodoServer, TodoEntry}

  setup do
    {:ok, server} = TodoServer.start_link
    {:ok, server: server}
  end

  test "entries/1 returns all entries", %{server: server} do
    TodoServer.add_entry(server, %TodoEntry{})
    assert TodoServer.entries(server) |> length == 1
  end

  test "add_entry/2 creates a new entry", %{server: server} do
    TodoServer.add_entry(server, %TodoEntry{title: "Nice little entry"})
    new_entry = TodoServer.entries(server) |> List.first
    assert new_entry.title == "Nice little entry"
  end

  test "update_entry/3 changes an existing entry", %{server: server} do
    TodoServer.add_entry(server, %TodoEntry{title: "one two"})
    entry_id = TodoServer.entries(server) |> List.first |> Map.get(:id)
    TodoServer.update_entry(server, entry_id, fn(entry) ->
      %TodoEntry{entry | title: entry.title <> " three"}
    end)

    updated_entry = TodoServer.entries(server) |> List.first
    assert updated_entry.title == "one two three"
  end

  test "delete_entry/2 deletes an existing entry", %{server: server} do
    TodoServer.add_entry(server, %TodoEntry{title: "one two"})
    entry = TodoServer.entries(server) |> List.first
    TodoServer.delete_entry(server, entry.id)
    assert TodoServer.entries(server) |> length == 0
  end
end
