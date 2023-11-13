defmodule Todo.Database do
  @moduledoc """
  Persits information from different ToDo lists by employing a limited
  number of Workers.
  """
  alias Todo.DatabaseWorker

  @pool_size 3
  @db_folder "./persist"

  #  def start_link do
  #    File.mkdir_p!(@db_folder)
  #
  #    children = Enum.map(1..@pool_size, &worker_spec/1)
  #    Supervisor.start_link(children, strategy: :one_for_one)
  #  end
  #
  #  defp worker_spec(worker_id) do
  #    default_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
  #    Supervisor.child_spec(default_spec, id: worker_id)
  #  end
  #
  def child_spec(_) do
    IO.puts("Starting ToDo.DB...")
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [name: {:local, __MODULE__}, worker_module: Todo.DatabaseWorker, size: @pool_size],
      [@db_folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id -> DatabaseWorker.store(worker_id, key, data) end
    )

    #    key
    #    |> get_worker()
    #    |> DatabaseWorker.store(key, data)
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id -> DatabaseWorker.get(worker_id, key) end
    )

    #    key
    #    |> get_worker()
    #    |> DatabaseWorker.get(key)
  end

  #  defp get_worker(key) do
  #    :erlang.phash2(key, @pool_size) + 1
  #  end
end
