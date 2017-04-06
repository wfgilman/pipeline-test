defmodule Pipeline.DBLoader do

  use GenStage
  import IO.ANSI

  def start_link({id, subs}) do
    name = :"#{__MODULE__}#{id}"
    GenStage.start_link(__MODULE__, {subs, name}, name: name)
  end

  def init({subs, name}) do
    IO.puts(green() <> "#{name} subscribed!")
    producers =
      for id <- 1..subs do
        {:"Elixir.Pipeline.HTTPRequestor#{id}", max_demand: 3}
      end
    {:consumer, name, subscribe_to: producers}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      # Load response from external service to the database.
      :ok = :timer.sleep(500)
      if String.last(event) == "9", do: raise("#{state} just Crashed!")
      IO.puts(yellow() <> event <> " |> Processed by #{state}")
    end
    {:noreply, [], state}
  end

end
