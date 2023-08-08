defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  test "a new todo list is a map" do
    assert is_map(TodoList.new())
  end

  test "add an entry results in a date=>[string] map" do
    list = TodoList.new()

    assert TodoList.add_entry(list, ~D[2022-01-01], "Buy coffee") == %{
             ~D[2022-01-01] => ["Buy coffee"]
           }
  end

  test "add entry to existing date prepends to list" do
    list = TodoList.new() |> TodoList.add_entry(~D[2022-01-01], "Buy coffee")

    assert TodoList.add_entry(list, ~D[2022-01-01], "Take a shower") == %{
             ~D[2022-01-01] => ["Take a shower", "Buy coffee"]
           }
  end

  test "retrive list of todos for a given date" do
    list = TodoList.new() |> TodoList.add_entry(~D[2022-01-01], "Buy coffee")

    assert TodoList.entries(list, ~D[2022-01-01]) == ["Buy coffee"]
  end
end
