defmodule Todo.Server do
  @moduledoc """
  Creates an async Todo list manager.
  """
  use GenServer

  @impl GenServer
  def init(entries \\ []) do
    {:ok, Todo.List.new(entries)}
  end

  @impl GenServer
  def handle_cast({:add, entry}, current_state) do
    {:noreply, Todo.List.add_entry(current_state, entry)}
  end

  def handle_cast({:remove, id}, current_state) do
    {:noreply, Todo.List.delete_entry(current_state, id)}
  end

  def handle_cast({:update, id, field, new_data}, current_state) do
    {:noreply, Todo.List.update_entry(current_state, {id, field}, new_data)}
  end

  def handle_cast({:print}, current_state) do
    IO.puts(current_state)
    {:noreply, current_state}
  end

  @impl GenServer
  def handle_call({:retrieve, date}, _from, current_state) do
    {:reply, Todo.List.entries(current_state, date), current_state}
  end

  def start(entries \\ []) do
    GenServer.start(Todo.Server, entries)
  end

  def add_entry(server, entry) do
    GenServer.cast(server, {:add, entry})
  end

  def remove_entry(server, id) do
    GenServer.cast(server, {:remove, id})
  end

  def update_entry(server, id, field, new_data) do
    GenServer.cast(server, {:update, id, field, new_data})
  end

  def retrieve(server, date) do
    GenServer.call(server, {:retrieve, date})
  end

  def print(server) do
    GenServer.cast(server, {:print})
  end
end
