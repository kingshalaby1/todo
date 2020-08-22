defmodule Todo.DatabaseWorker do
  @moduledoc """
  Performs read/write operations on the database
  """
  use GenServer

  def start(db_folder) do
    IO.puts("in Todo.DatabaseWorker.start #{inspect(self())}")
    GenServer.start(__MODULE__, db_folder)
  end

  def store(worker, key, data) do
    IO.puts("in Todo.DatabaseWorker.store #{inspect(self())}")
    GenServer.cast(worker, {:store, key, data})
  end

  def get(worker, key) do
    IO.puts("in Todo.DatabaseWorker.get #{inspect(self())}")
    GenServer.call(worker, {:get, key})
  end

  def init(db_folder) do
    IO.puts("in Todo.DatabaseWorker.init #{inspect(self())}")
    {:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    IO.puts("in Todo.DatabaseWorker.handle_cast #{inspect(self())}")

    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    IO.puts("in Todo.DatabaseWorker.handle_call() #{inspect(self())}")

    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
