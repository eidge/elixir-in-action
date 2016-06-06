defmodule TodoApp.TodoEntryTest do
  use ExUnit.Case

  alias TodoApp.TodoEntry

  test "new/0 creates a new TodoEntry" do
    assert TodoEntry.new == %TodoEntry{}
  end

  test "new/1 creates a new TodoEntry with defined fields" do
    assert TodoEntry.new(title: "What?", date: {1992, 02, 04}) ==
      %TodoEntry{title: "What?", date: {1992, 02, 04}}
  end
end
