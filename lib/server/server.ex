defmodule TodoList.Server do
  @moduledoc """
  Creates an async Todo list manager.
  """

  def start(entries \\ []) do
    pid = spawn(fn -> listen(TodoList.new(entries)) end)
    Process.register(pid, :todo)
  end

  defp listen(todo_list) do
    new_todo =
      receive do
        {:add, entry} ->
          TodoList.add_entry(todo_list, entry)

        {:remove, id} ->
          TodoList.delete_entry(todo_list, id)

        {:update, id, field, new_data} ->
          TodoList.update_entry(todo_list, {id, field}, new_data)

        {:retrieve, caller, date} ->
          send(caller, {:result, TodoList.entries(todo_list, date)})
          todo_list

        {:print} ->
          IO.puts(todo_list)
          todo_list

        invalid_msg ->
          {:error, "Invalid msg: #{invalid_msg}"}
      end

    listen(new_todo)
  end

  def add_entry(entry) do
    send(:todo, {:add, entry})
  end

  def remove_entry(id) do
    send(:todo, {:remove, id})
  end

  def update_entry(id, field, new_data) do
    send(:todo, {:update, id, field, new_data})
  end

  def retrieve(date) do
    send(:todo, {:retrieve, self(), date})

    receive do
      {:result, result} -> result
    after
      2000 -> {:error, :timeout}
    end
  end

  def print() do
    send(:todo, {:print})
  end
end
