defmodule Pipeline.Source do

  use GenServer

  def start_link(count) do
    GenServer.start_link(__MODULE__, count, name: __MODULE__)
  end

  def create(count) do
    GenServer.cast(__MODULE__, {:create, count})
  end

  def get(limit) do
    GenServer.call(__MODULE__, {:take, limit})
  end

  def init(count) do
    list = for n <- 1..count, do: n
    {:ok, list}
  end

  def handle_call({:take, limit}, _from, state) do
    {events, new_state} = Enum.split(state, limit)
    {:reply, events, new_state}
  end

  def handle_cast({:create, count}, state) do
    events = for n <- 1..count, do: n
    {:noreply, state ++ events}
  end

end
