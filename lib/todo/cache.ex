defmodule Todo.Cache do
  @moduledoc """
  Manages the ToDo list servers by recovering created instances or creating
  new ones.
  """

  def server_process(todo_list_name) do
    existing_process(todo_list_name) || new_process(todo_list_name)
  end

  defp existing_process(todo_list_name) do
    Todo.Server.whereis(todo_list_name)
  end

  defp new_process(todo_list_name) do
    case DynamicSupervisor.start_child(
           __MODULE__,
           {Todo.Server, todo_list_name}
         ) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_link do
    IO.puts("Starting ToDo cache...")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end
end
