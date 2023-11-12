defmodule Todo.ProcessRegistry do
  @moduledoc """
  A simple registry to recover worker information for the database module.
  """
  def start_link do
    {:ok,
     spawn(fn ->
       Process.flag(:trap_exit, true)
       Process.register(self(), __MODULE__)
       :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
       loop_reg()
     end)}
  end

  defp loop_reg do
    receive do
      {:EXIT, pid, _reason} ->
        :ets.match_delete(__MODULE__, {:_, pid})
        loop_reg()

      {:exit} ->
        :exit
    end
  end

  def register(key) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(__MODULE__, {key, self()}) do
      :ok
    else
      :error
    end
  end

  def whereis(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, val}] -> val
      [] -> nil
    end
  end
end
