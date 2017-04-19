defmodule Pipeline.DBLoader do

  use GenStage
  import IO.ANSI

  def start_link({id, subs}) do
    name = {:via, Registry, {Pipeline.Registry, {DBLoader, id}}}
    GenStage.start_link(__MODULE__, {id, subs}, name: name)
  end

  def init({id, subs}) do
    IO.puts(green() <> "{DBLoader, #{id}} subscribed!")
    producers =
      for sub <- 1..subs do
        name = {:via, Registry, {Pipeline.Registry, {HTTPRequestor, sub}}}
        {name, max_demand: 3}
      end
    {:consumer, "{DBLoader, #{id}}", subscribe_to: producers}
  end

  def handle_events(events, _from, name) do
    for event <- events do
      # Load response from external service to the database.
      :ok = :timer.sleep(500)
      if String.last(event) == "9", do: raise("#{name} just Crashed!")
      IO.puts(yellow() <> event <> " |> Processed by #{name}")
    end
    {:noreply, [], name}
  end

end
