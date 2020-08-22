defmodule Todo.Server do
  @moduledoc """
  Allows multiple clients to work on a single to-do list
  state: {list_name::string, %List{}}
  """
  use GenServer

  def start(todo_name) do
    IO.puts("in Todo.Server.start #{inspect(self())}")
    GenServer.start(Todo.Server, todo_name)
  end

  def add_entry(todo_server, new_entry) do
    IO.puts("in Todo.Server.add_entry #{inspect(self())}")
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    IO.puts("in Todo.Server.entries #{inspect(self())}")
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(list_name) do
    IO.puts("in Todo.Server.init #{inspect(self())}")
    {:ok, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    IO.puts("in Todo.Server.handle_cast #{inspect(self())}")
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    IO.puts("in Todo.Server.handle_call #{inspect(self())}")

    {
      :reply,
      Todo.List.entries(todo_list, date),
      {list_name, todo_list}
    }
  end
end
