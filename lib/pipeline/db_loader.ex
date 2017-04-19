defmodule Pipeline.DBLoader do

  use GenStage
  import IO.ANSI

  def start_link({id, subs}) do
    {:ok, pid} = GenStage.start_link(__MODULE__, {id, subs})
    {:ok, _} = Registry.register(Registry.Pipeline, {DBLoader, id}, pid)
  end

  def init({id, subs}) do
    IO.puts(green() <> "{DBLoader, #{id}} subscribed!")
    producers =
      for sub <- 1..subs do
        [{_, pid}] = Registry.lookup(Registry.Pipeline, {HTTPRequestor, sub})
        IO.inspect pid
        pid
      end
    {:consumer, "DBLoader, #{id}", subscribe_to: producers}
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
