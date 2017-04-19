defmodule Pipeline do
   use Application

   @http_requestors 5
   @db_loaders 3

  def start(_, _) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Pipeline.Source, [100]), # Records in an in-memory queue.
      worker(Pipeline.Producer, []),
      supervisor(Registry, [:unique, Pipeline.Registry])
    ]

    http_requestors =
      for id <- 1..@http_requestors do
        worker(Pipeline.HTTPRequestor, [id], id: {HTTPRequestor, id})
      end

    db_loaders =
      for id <- 1..@db_loaders do
        worker(Pipeline.DBLoader, [{id, @http_requestors}], id: {DBLoader, id})
      end

    opts = [strategy: :one_for_one, name: Pipeline.Supervisor, max_restarts: 10]
    Supervisor.start_link(children ++ http_requestors ++ db_loaders, opts)
  end
end
