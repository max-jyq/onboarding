defmodule TodoApi.Workers.CompleteDueTodosWorker do
  use Oban.Worker, queue: :default

  alias Oban.Job
  alias TodoApi.Todos

  @impl Oban.Worker
  def perform(%Job{args: args}) do
    now = now_from_args(args)
    {:ok, _updated_count} = Todos.complete_todos_due_now(now)
    :ok
  end

  defp now_from_args(%{"run_at" => run_at}) when is_binary(run_at) do
    case DateTime.from_iso8601(run_at) do
      {:ok, datetime, _offset} -> datetime
      _ -> DateTime.utc_now()
    end
  end

  defp now_from_args(_args), do: DateTime.utc_now()
end
