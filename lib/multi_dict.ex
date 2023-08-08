defmodule MultiDict do
  @moduledoc """
  A dictionary that holds multiple values for a single key.
  """
  @type t :: %{any() => [any]}

  @spec new :: t()
  @doc """
  Generates an empty multi dict.
  """
  def new(), do: %{}

  @spec add(t(), any(), any()) :: t()
  @doc """
  Add a new entry `todo` to `todo_list` on `date`.
  If the date already has an activity, adds it to the current list.

  ## Examples

      iex> dict = MultiDict.new()
      iex> MultiDict.add(dict, :cars, "Honda")
      %{cars: ["Honda"]}

  """
  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  @spec get(t(), any()) :: [any()]
  @doc """
  Retrieves all entries for a given `date` in `todo_list`.

  ## Examples

      iex> dict = MultiDict.new() |> MultiDict.add(:cars, "VW")
      iex> MultiDict.get(dict, :cars)
      ["VW"]
  """
  def get(dict, key) do
    Map.get(dict, key, [])
  end
end
