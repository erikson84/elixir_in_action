defmodule Calculator do
  @moduledoc """
  Asynchronous calculator for basic OTP usage.
  """

  @doc """
  Starts the calculator server with initial `value`.
  """
  @spec start(float()) :: pid
  def start(value \\ 0.0) do
    spawn(fn -> listen(value) end)
  end

  defp listen(value) do
    new_value =
      receive do
        {:value, caller} ->
          send(caller, {:value, value})
          value

        {:add, number} ->
          value + number

        {:subtract, number} ->
          value - number

        {:multiply, number} ->
          value * number

        {:divide, number} ->
          value / number

        invalid_msg ->
          {:error, "Invalid message: #{invalid_msg}"}
      end

    listen(new_value)
  end

  @spec add(pid(), number()) :: any()
  @doc """
  Adds `number` to the `server` state number.
  """
  def add(server, number), do: send(server, {:add, number})

  @spec subtract(pid(), number()) :: any()
  @doc """
  Subtracts `number` from the `server` state number.
  """
  def subtract(server, number), do: send(server, {:subtract, number})
  @spec multiply(pid(), number()) :: any()
  @doc """
  Multiplies `number` by the `server` state number.
  """
  def multiply(server, number), do: send(server, {:multiply, number})

  @spec divide(pid(), number()) :: any()
  @doc """
  Divides the `server` state number by `number`.
  """
  def divide(server, number), do: send(server, {:divide, number})

  def value(server) do
    send(server, {:value, self()})

    receive do
      {:value, value} -> value
    end
  end
end
