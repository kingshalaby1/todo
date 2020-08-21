defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def init(_) do
    File.mkdir_p!(@db_folder)

    workers =
      Enum.reduce(0..2, %{}, fn index, acc ->
        {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
        Map.put(acc, index, pid)
      end)

    {:ok, workers}
  end

  def handle_call({:choose_worker, list_name}, _, workers) do
    key = :erlang.phash2(list_name, 3)
    worker = Map.fetch!(workers, key)

    {:reply, worker, workers}
  end

  defp choose_worker(list_name) do
    GenServer.call(__MODULE__, {:choose_worker, list_name})
  end
end
