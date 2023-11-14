defmodule Todo.Server do
  @moduledoc """
  Creates an async Todo list manager.
  """

  @expiry_idle_timeout :timer.seconds(10)

  use GenServer, restart: :temporary

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:add, entry}, {name, list}) do
    new_list = Todo.List.add_entry(list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  def handle_cast({:remove, id}, {name, list}) do
    new_list = Todo.List.delete_entry(list, id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  def handle_cast({:update, id, field, new_data}, {name, list}) do
    new_list = Todo.List.update_entry(list, {id, field}, new_data)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  def handle_cast({:print}, {name, list}) do
    IO.puts(list)
    {:noreply, {name, list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:retrieve, date}, _from, {name, list}) do
    {:reply, Todo.List.entries(list, date), {name, list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, {name, list}) do
    IO.puts("Stopping ToDo Server for #{name}")
    {:stop, :normal, {name, list}}
  end

  def start_link(name) do
    IO.puts("Starting ToDo server #{name}...")
    GenServer.start_link(Todo.Server, name, name: global_name(name))
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

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end
end
