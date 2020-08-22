defmodule Todo.Database do
  @moduledoc """
  Manages a pool of database workers, and forwards database requests to them
  """
  use GenServer

  @db_folder "./persist"

  def start do
    IO.puts("in Todo.Database.start #{inspect(self())}")
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    IO.puts("in Todo.Database.store #{inspect(self())}")

    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    IO.puts("in Todo.Database.get #{inspect(self())}")

    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def init(_) do
    IO.puts("in Todo.Database.init #{inspect(self())}")
    File.mkdir_p!(@db_folder)

    workers =
      Enum.reduce(0..2, %{}, fn index, acc ->
        {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
        Map.put(acc, index, pid)
      end)

    {:ok, workers}
  end

  def handle_call({:choose_worker, list_name}, _, workers) do
    IO.puts("in Todo.Database.handle_call #{inspect(self())}")
    key = :erlang.phash2(list_name, 3)
    worker = Map.fetch!(workers, key)

    {:reply, worker, workers}
  end

  defp choose_worker(list_name) do
    IO.puts("in Todo.Database.choose_worker #{inspect(self())}")
    GenServer.call(__MODULE__, {:choose_worker, list_name})
  end
end
