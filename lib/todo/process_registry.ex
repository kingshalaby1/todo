defmodule Todo.ProcessRegistry do
  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("Starting ProcessRegistry.")
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @spec via_tuple(any) :: {:via, Registry, {Todo.ProcessRegistry, any}}
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  @spec child_spec(any) :: %{
          :id => any,
          :start => {atom, atom, [any]},
          optional(:modules) => :dynamic | [atom],
          optional(:restart) => :permanent | :temporary | :transient,
          optional(:shutdown) => :brutal_kill | :infinity | non_neg_integer,
          optional(:type) => :supervisor | :worker
        }
  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
