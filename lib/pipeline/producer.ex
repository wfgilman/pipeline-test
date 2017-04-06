defmodule Pipeline.Producer do

  use GenStage
  import IO.ANSI

  def start_link do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer, :ok}
  end

  def handle_demand(demand, state) do
    events = Pipeline.Source.get(demand)
    IO.inspect(events)
    {:noreply, events, state}
  end

end
