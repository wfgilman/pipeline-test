defmodule Pipeline.HTTPRequestor do

  use GenStage
  import IO.ANSI

  def start_link(id) do
    name = :"#{__MODULE__}#{id}"
    GenStage.start_link(__MODULE__, name, name: name)
  end

  def init(name) do
    IO.puts(green() <> "#{name} subscribed!")
    {:producer_consumer, name, subscribe_to: [{Pipeline.Producer, max_demand: 10}]}
  end

  def handle_events(events, _from, state) do
    modified_events =
      for event <- events do
        # Make an HTTP request to external service. Wait for response.
        :ok = :timer.sleep(2_000)
        if event in [15, 47], do: raise("#{state} just Crashed")
        IO.puts(yellow() <> "Processed by #{state}: #{event}")
        
        "Processed by #{state}: #{event}"
      end
    {:noreply, modified_events, state}
  end

end
