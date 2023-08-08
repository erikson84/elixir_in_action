defmodule TodoList do
  @moduledoc """
  A simples todo list.
  """
  defstruct auto_id: 1, entries: %{}
  @type t :: %__MODULE__{}
  @typep entry :: %{date: Date.t(), title: String.t()}

  @spec new([entry] | []) :: t()
  @doc """
  Generates an empty todo list
  """
  def new(entries \\ []) do
    entries
    |> Enum.reduce(%TodoList{}, fn el, acc -> add_entry(acc, el) end)
  end

  @spec add_entry(t(), entry()) :: t()
  @doc """
  Add a new entry `todo` to `todo_list` on `date`.
  If the date already has an activity, adds it to the current list.

  ## Examples

      iex> todos = TodoList.new()
      iex> TodoList.add_entry(todos, %{date: ~D[2022-12-01], title: "Clean the garden"})
      %TodoList{auto_id: 2,
      entries: %{1 => %{date: ~D[2022-12-01], id: 1, title: "Clean the garden"}}}

  """
  def add_entry(todo_list, entry) do
    new_entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, new_entry)
    %TodoList{auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  @spec entries(t(), Date.t()) :: [entry()]
  @doc """
  Retrieves all entries for a given `date` in `todo_list`.

  ## Examples

      iex> todos = TodoList.new() |> TodoList.add_entry(%{date: ~D[2022-01-01], title: "Shave"})
      iex> TodoList.entries(todos, ~D[2022-01-01])
      [%{date: ~D[2022-01-01], id: 1, title: "Shave"}]
  """
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_id, %{date: id_date}} -> date == id_date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end

  @spec update_entry(t(), {non_neg_integer(), :date | :title}, Date.t() | String.t()) :: t()
  @doc """
  Update an entry with given `id` changing its `date` or `title`.
  """
  def update_entry(todo_list, {id, :date}, date) do
    case Map.get(todo_list, id) do
      :error -> todo_list
      {:ok, entry} -> Map.put(todo_list, id, %{entry | date: date})
    end
  end

  def update_entry(todo_list, {id, :title}, title) do
    case Map.get(todo_list, id) do
      :error -> todo_list
      {:ok, entry} -> Map.put(todo_list, id, %{entry | title: title})
    end
  end

  @spec delete_entry(t(), non_neg_integer()) :: t()
  @doc """
  Removes an entry from `todo_list` by its numerical `id`.
  """
  def delete_entry(todo_list, id) do
    {_entry, todo_list} = Map.pop(todo_list, id)
    todo_list
  end
end

defmodule TodoList.CsvImporter do
  @moduledoc """
  Import todo list from CSV file with `Date | Title` format.
  """
  @spec import!(String.t()) :: TodoList.t()
  def import!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.map(fn [date, title] -> %{date: Date.from_iso8601!(date), title: title} end)
    |> TodoList.new()
  end
end
