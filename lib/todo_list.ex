defmodule TodoList do
  @moduledoc """
  A simples todo list.
  """
  defstruct auto_id: 1, entries: %{}
  @type t :: %__MODULE__{}
  @typep entry :: %{date: Date.t(), title: String.t()}

  @spec new() :: t()
  @doc """
  Generates an empty todo list
  """
  def new(), do: %__MODULE__{}

  @spec add_entry(t(), entry()) :: t()
  @doc """
  Add a new entry `todo` to `todo_list` on `date`.
  If the date already has an activity, adds it to the current list.

  ## Examples

      iex> todos = TodoList.new()
      iex> TodoList.add_entry(todos, ~D[2022-12-01], "Clean the garden")
      %{~D[2022-12-01] => ["Clean the garden"]}

  """
  def add_entry(todo_list, entry) do
    new_entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, new_entry)
    %TodoList{auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  @spec entries(t(), Date.t()) :: [String.t()]
  @doc """
  Retrieves all entries for a given `date` in `todo_list`.

  ## Examples

      iex> todos = TodoList.new() |> TodoList.add_entry(~D[2022-01-01], "Shave")
      iex> TodoList.entries(todos, ~D[2022-01-01])
      ["Shave"]
  """
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_id, %{date: id_date}} -> date == id_date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end
end
