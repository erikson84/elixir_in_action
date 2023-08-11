defmodule DatabaseServer do
  @moduledoc """
  A database query server and client interface.
  """

  @doc """
  Start the server and returns its PID.
  """
  def start do
    spawn(fn ->
      connection = :rand.uniform(1000)
      listen_request(connection)
    end)
  end

  defp listen_request(connection) do
    receive do
      {:run_query, caller, query} ->
        send(caller, {:query_result, process_query(connection, query)})
    end

    listen_request(connection)
  end

  defp process_query(connection, query) do
    Process.sleep(2000)
    "Connection #{connection}: #{query} has been processed."
  end

  @doc """
  Sends request `query` to `server` asynchronously.
  """
  @spec make_request(pid(), String.t()) :: :ok | :error
  def make_request(server, query) do
    caller = self()
    send(server, {:run_query, caller, query})
  end

  @doc """
  Reads received queries or gives a timeout error.
  """
  @spec get_result :: String.t() | {:error, :timeout}
  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end
end
