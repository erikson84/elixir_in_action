defmodule Todo.Application do
  @moduledoc """
  Initializes the Todo List application and the necessary processes.
  """
  use Application

  def start(_, _) do
    children =
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache,
        Todo.Web
      ]

    opts = [strategy: :one_for_one, name: Todo.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
