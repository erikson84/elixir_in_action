defmodule Todo.ProcessRegistry do
  use GenServer

  @moduledoc """
  A simple registry to recover worker information for the database module.
  """
  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, key}, {pid, _}, state) do
    case Map.fetch(state, key) do
      {:ok, _} ->
        {:reply, :error, state}

      :error ->
        Process.link(pid)
        {:reply, :ok, Map.put(state, key, pid)}
    end
  end

  def handle_call({:whereis, key}, _from, state) do
    {:reply, state[key], state}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    {key, _val} = Enum.find(state, fn {_key, val} -> val == pid end)
    {:noreply, Map.delete(state, key)}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(key) do
    GenServer.call(__MODULE__, {:register, key})
  end

  def whereis(key) do
    GenServer.call(__MODULE__, {:whereis, key})
  end
end
