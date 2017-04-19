defmodule Pipeline.DBLoader do

  use GenStage
  import IO.ANSI

  def start_link({id, subs}) do
    {:ok, pid} = GenStage.start_link(__MODULE__, {id, subs})
    {:ok, _} = Registry.register(Registry.Pipeline, {DBLoader, id}, pid)
    {:ok, pid}
  end

  def init({id, subs}) do
    IO.puts(green() <> "{DBLoader, #{id}} subscribed!")
    producers =
      for sub <- 1..subs do
        [{_, pid}] = Registry.lookup(Registry.Pipeline, {HTTPRequestor, sub})
        {pid, max_demand: 3}
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
