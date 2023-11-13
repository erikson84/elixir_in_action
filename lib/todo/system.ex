defmodule Todo.System do
  @moduledoc """
  Initiates the ToDo list system employing a Supervisor with the Todo.Cache module.
  """

  def start_link do
    Supervisor.start_link(
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end
