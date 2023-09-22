defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def init(_) do
    workers = 0..2
    |> Enum.map(fn idx -> {:ok, worker} = Todo.Database.Worker.start(@db_folder)
    {idx, worker} end)
    |> Map.new()

    {:ok, workers}
  end

  def handle_cast({:store, key, data}, workers) do
    worker = get_worker(key, workers)
    Todo.Database.Worker.store(worker, key, data)

    {:noreply, workers}
  end

  def handle_call({:get, key}, _, workers) do
    worker = get_worker(key, workers)
    data = Todo.Database.Worker.get(worker, key)
      case File.read(file_name(key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, workers}
  end

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end

  defp get_worker(key, workers) do
    Map.get(workers, :erlang.phash2(key, 3))
  end
end
