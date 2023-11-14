defmodule Todo.DatabaseWorker do
  @moduledoc """
  A worker to read and write persistent data, called from the Todo.Database module.
  """
  use GenServer

  def init(db_folder) do
    node_folder =
      get_node()
      |> then(&Path.join(db_folder, &1))

    File.mkdir_p!(node_folder)
    {:ok, node_folder}
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
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker_id, key, data) do
    GenServer.cast(worker_id, {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(worker_id, {:get, key})
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end

  defp get_node do
    Node.self()
    |> Atom.to_string()
    |> String.replace(~r/@.*/, "")
  end
end
