defmodule Todo.CacheTest do
  use ExUnit.Case

  test "Verify servers pids" do
    # {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process("Bob's list")

    assert bob_pid != Todo.Cache.server_process("Alice's list")
    assert bob_pid == Todo.Cache.server_process("Bob's list")
  end

  test "Verify Todo operations with server" do
    # {:ok, cache} = Todo.Cache.start()

    alice = Todo.Cache.server_process("alice")
    entry = %{date: ~D[2022-01-01], title: "Shave my armpits."}
    Todo.Server.add_entry(alice, entry)
    entries = Todo.Server.retrieve(alice, ~D[2022-01-01])

    assert [%{date: ~D[2022-01-01], title: "Shave my armpits."}] = entries
  end
end
