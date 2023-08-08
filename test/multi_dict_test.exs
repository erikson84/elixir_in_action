defmodule MultiDicTest do
  use ExUnit.Case
  doctest MultiDict

  test "a new multidict is a map" do
    assert is_map(MultiDict.new())
  end

  test "add an entry results in a any=>[any] map" do
    list = MultiDict.new()

    assert MultiDict.add(list, :cats, "Siamese") == %{
             cats: ["Siamese"]
           }
  end

  test "add entry to existing key prepends to list" do
    list = MultiDict.new() |> MultiDict.add(:cats, "Burmese")

    assert MultiDict.add(list, :cats, "Angora") == %{
             cats: ["Angora", "Burmese"]
           }
  end

  test "retrive list a given key" do
    list = MultiDict.new() |> MultiDict.add(:cats, "Stray")

    assert MultiDict.get(list, :cats) == ["Stray"]
  end
end
