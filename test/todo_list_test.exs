defmodule TodoListTest do
  use ExUnit.Case
  doctest TodoList

  test "a new todo list is a TodoList struct" do
    assert is_struct(TodoList.new(), TodoList)
  end

  test "add an entry results updated TodoList struct" do
    list = TodoList.new()

    assert TodoList.add_entry(list, %{date: ~D[2022-01-01], title: "Buy coffee"}) == %TodoList{
             auto_id: 2,
             entries: %{1 => %{date: ~D[2022-01-01], id: 1, title: "Buy coffee"}}
           }
  end

  test "add entry to existing date just adds another entry" do
    list = TodoList.new() |> TodoList.add_entry(%{date: ~D[2022-01-01], title: "Buy coffee"})

    assert TodoList.add_entry(list, %{date: ~D[2022-01-01], title: "Take a shower"}) == %TodoList{
             auto_id: 3,
             entries: %{
               1 => %{date: ~D[2022-01-01], id: 1, title: "Buy coffee"},
               2 => %{date: ~D[2022-01-01], id: 2, title: "Take a shower"}
             }
           }
  end

  test "retrive list of todos for a given date" do
    list = TodoList.new() |> TodoList.add_entry(%{date: ~D[2022-01-01], title: "Buy coffee"})

    assert TodoList.entries(list, ~D[2022-01-01]) == [
             %{date: ~D[2022-01-01], id: 1, title: "Buy coffee"}
           ]
  end
end
