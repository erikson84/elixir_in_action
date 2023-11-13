Extrace.calls([
  {Todo.ProcessRegistry, :register_name, fn _ -> :return end},
  {Todo.ProcessRegistry, :send, fn _ -> :return end},
  {GenServer, :start_link, fn _ -> :return end},
  {:gen, :start, fn _ -> :return end}],
  100, [scope: :local])

  Todo.ProcessRegistry.start_link

  Todo.DatabaseWorker.start_link({"./persist", 1})
