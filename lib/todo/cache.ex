defmodule Todo.Cache do
  @moduledoc """
  Maintains a collection of to-do servers and is responsible for their creation and discovery
  state here is a map containing %{"list name" => "pid of GenServer that manages the list"}
  """
  use GenServer

  def start() do
    IO.puts("in Todo.Cache.start #{inspect(self())}")
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  asynchronously, get the pid for list server, create it if not found, and add it to the map state as `%{"list name" => pid}`
  """
  def server_process(cache_pid, todo_list_name) do
    IO.puts("in Todo.Cache.server_process #{inspect(self())}")
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  def init(_) do
    IO.puts("in Todo.Cache.init #{inspect(self())}")
    Todo.Database.start()
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    IO.puts("in Todo.Cache.handle_call #{inspect(self())}")

    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        {:reply, new_server, Map.put(todo_servers, todo_list_name, new_server)}
    end
  end
end
