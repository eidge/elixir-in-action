defmodule TodoApp.DatabaseTest do
  use ExUnit.Case

  alias TodoApp.Database

  setup do
    Database.start("./persist")
    Database.store("existing-record", "some data")
    :ok
  end

  test "get/1 returns nil when no data is found for a given key" do
    assert Database.get("non-existing-record") == nil
  end

  test "get/1 returns persisted data for a given key" do
    assert Database.get("existing-record") == "some data"
  end

  test "store/2 stores a new value in the database" do
    record = %{name: "new record"}
    Database.store("new-record", record)
    assert Database.get("new-record") == record
  end

  test "store/2 overwrites existing record" do
    assert Database.get("existing-record") == "some data"
    Database.store("existing-record", "new data")
    assert Database.get("existing-record") == "new data"
  end
end
