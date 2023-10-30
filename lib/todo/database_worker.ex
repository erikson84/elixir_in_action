defmodule Todo.DatabaseWorker do
  @moduledoc """
  A worker to read and write persistent data, called from the Todo.Database module.
  """
  use GenServer

  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    key
    |> then(&file_name(db_folder, &1))
    |> File.write(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  def start_link(db_folder) do
    IO.puts("Starting DB worker...")
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(server, key, data) do
    GenServer.cast(server, {:store, key, data})
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
