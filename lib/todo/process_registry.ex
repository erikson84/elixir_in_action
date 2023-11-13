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

  def register_name(key, _value) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(__MODULE__, {key, self()}) do
      :yes
    else
      :no
    end
  end

  def unregister_name(key) do
    Process.unlink(Process.whereis(__MODULE__))
    :ets.match_delete(__MODULE__, {key, :_})
  end

  def whereis_name(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, val}] -> val
      [] -> :undefined
    end
  end

  def send(key, msg) do
    case whereis_name(key) do
      pid when is_pid(pid) -> Kernel.send(pid, msg)
      _ -> :error
    end
  end

  def via_tuple(key) do
    {:via, __MODULE__, key}
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end
end
