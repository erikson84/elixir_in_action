defmodule Todo.Database do
  @moduledoc """
  Persits information from different ToDo lists by employing a limited
  number of Workers.
  """
  alias Todo.DatabaseWorker

  @pool_size 3
  @db_folder "./persist"

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
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id -> DatabaseWorker.get(worker_id, key) end
    )
  end
end
