defmodule TodoListTest do
  use ExUnit.Case
  doctest Todo.List

  test "a new todo list is a TodoList struct" do
    assert is_struct(Todo.List.new(), Todo.List)
  end

  test "add an entry results updated TodoList struct" do
    list = Todo.List.new()

    assert Todo.List.add_entry(list, %{date: ~D[2022-01-01], title: "Buy coffee"}) == %Todo.List{
             auto_id: 2,
             entries: %{1 => %{date: ~D[2022-01-01], id: 1, title: "Buy coffee"}}
           }
  end

  test "add entry to existing date just adds another entry" do
    list = Todo.List.new() |> Todo.List.add_entry(%{date: ~D[2022-01-01], title: "Buy coffee"})

    assert Todo.List.add_entry(list, %{date: ~D[2022-01-01], title: "Take a shower"}) ==
             %Todo.List{
               auto_id: 3,
               entries: %{
                 1 => %{date: ~D[2022-01-01], id: 1, title: "Buy coffee"},
                 2 => %{date: ~D[2022-01-01], id: 2, title: "Take a shower"}
               }
             }
  end

  test "retrive list of todos for a given date" do
    list = Todo.List.new() |> Todo.List.add_entry(%{date: ~D[2022-01-01], title: "Buy coffee"})

    assert Todo.List.entries(list, ~D[2022-01-01]) == [
             %{date: ~D[2022-01-01], id: 1, title: "Buy coffee"}
           ]
  end
end
