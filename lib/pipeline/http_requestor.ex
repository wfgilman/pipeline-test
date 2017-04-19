defmodule Pipeline.HTTPRequestor do

  use GenStage
  import IO.ANSI

  def start_link(id) do
    name = {:via, Registry, {Pipeline.Registry, {HTTPRequestor, id}}}
    GenStage.start_link(__MODULE__, id, name: name)
  end

  def init(id) do
    IO.puts(green() <> "{HTTPRequestor, #{id}} subscribed!")
    {:producer_consumer, "{HTTPRequestor, #{id}}", subscribe_to: [{Pipeline.Producer, max_demand: 10}]}
  end

  def handle_events(events, _from, name) do
    modified_events =
      for event <- events do
        # Make an HTTP request to external service. Wait for response.
        :ok = :timer.sleep(1_000)
        if event in [15, 47], do: raise("#{name} just Crashed")
        IO.puts(yellow() <> "Processed by #{name}: #{event}")
        "Processed by #{name}: #{event}"
      end
    {:noreply, modified_events, name}
  end

end
