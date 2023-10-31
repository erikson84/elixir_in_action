defmodule Todo.Cache do
  @moduledoc """
  Manages the ToDo list servers by recovering created instances or creating
  new ones.
  """

  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def start_link() do
    IO.puts("Starting ToDo cache...")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def start_child(todo_list_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Todo.Server, todo_list_name}
    )
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link,  []},
      type: :supervisor
    }
  end
end
