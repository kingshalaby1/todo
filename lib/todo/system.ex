defmodule Todo.System do
  def start_link do
    IO.puts("Starting Sytem supervisor.")

    Supervisor.start_link(
      [Todo.ProcessRegistry, Todo.Database, Todo.Cache, Todo.Metrics],
      strategy: :one_for_one
    )
  end
end
