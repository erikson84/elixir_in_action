defmodule Todo.List do
  @moduledoc """
  A simples todo list.
  """
  defstruct auto_id: 1, entries: %{}
  @type t :: %Todo.List{}
  @typep entry :: %{date: Date.t(), title: String.t()}

  @spec new([entry] | []) :: t()
  @doc """
  Generates an empty todo list
  """
  def new(entries \\ []) do
    entries
    |> Enum.reduce(%Todo.List{}, fn el, acc -> add_entry(acc, el) end)
  end

  @spec add_entry(t(), entry()) :: t()
  @doc """
  Add a new entry `todo` to `todo_list` on `date`.
  If the date already has an activity, adds it to the current list.

  ## Examples

      iex> todos = Todo.List.new()
      iex> Todo.List.add_entry(todos, %{date: ~D[2022-12-01], title: "Clean the garden"})
      %Todo.List{auto_id: 2,
      entries: %{1 => %{date: ~D[2022-12-01], id: 1, title: "Clean the garden"}}}

  """
  def add_entry(todo_list, entry) do
    new_entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, new_entry)
    %Todo.List{auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  @spec entries(t(), Date.t()) :: [entry()]
  @doc """
  Retrieves all entries for a given `date` in `todo_list`.

  ## Examples

      iex> todos = Todo.List.new() |> Todo.List.add_entry(%{date: ~D[2022-01-01], title: "Shave"})
      iex> Todo.List.entries(todos, ~D[2022-01-01])
      [%{date: ~D[2022-01-01], id: 1, title: "Shave"}]
  """
  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_id, %{date: id_date}} -> date == id_date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end

  @spec update_entry(t(), {non_neg_integer(), :date | :title}, Date.t() | String.t()) :: t()
  @doc """
  Update an entry with given `id` changing its `:date` or `:title` field with `new_data`
  (assumed to be of the correct type).

   ## Examples

      iex> todos = Todo.List.new() |> Todo.List.add_entry(%{date: ~D[2022-12-01], title: "Clean the garden"})
      iex> Todo.List.update_entry(todos, {1, :date}, ~D[2022-12-10])
      %Todo.List{auto_id: 2,
      entries: %{1 => %{date: ~D[2022-12-10], id: 1, title: "Clean the garden"}}}

  """
  def update_entry(todo_list, {id, field}, new_data) do
    case Map.fetch(todo_list.entries, id) do
      :error ->
        todo_list

      {:ok, entry} ->
        %{todo_list | entries: Map.put(todo_list.entries, id, %{entry | field => new_data})}
    end
  end

  @spec delete_entry(t(), non_neg_integer()) :: t()
  @doc """
  Removes an entry from `todo_list` by its numerical `id`.

  ## Examples

      iex> todos = Todo.List.new() |> Todo.List.add_entry(%{date: ~D[2022-12-01], title: "Clean the garden"})
      iex> Todo.List.delete_entry(todos, 1)
      %Todo.List{auto_id: 2,
      entries: %{}}
  """
  def delete_entry(todo_list, id) do
    {_entry, entries} = Map.pop(todo_list.entries, id)
    %{todo_list | entries: entries}
  end
end

defimpl String.Chars, for: Todo.List do
  def to_string(todo_list) do
    todo_list.entries
    |> Enum.map(fn {_id, %{date: date, title: title}} -> "#{date}: #{title}\n" end)
    |> Enum.sort()
    |> Enum.reduce("# To-Do List\n\n", &(&2 <> &1))
  end
end

defimpl Collectable, for: Todo.List do
  def into(todo_list) do
    {todo_list, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todo.List.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_todo_list, :halt), do: :ok
end

defmodule Todo.List.CsvImporter do
  @moduledoc """
  Import todo list from CSV file with `Date | Title` format.
  """
  @spec import!(String.t()) :: Todo.List.t()
  def import!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.map(fn [date, title] -> %{date: Date.from_iso8601!(date), title: title} end)
    |> Todo.List.new()
  end
end
