defmodule TodoApi.Workers.CompleteDueTodosWorkerTest do
  use TodoApi.DataCase, async: true

  alias Oban.Job
  alias TodoApi.Todos
  alias TodoApi.Workers.CompleteDueTodosWorker

  test "perform/1 completes todos that match the provided run_at minute" do
    run_at = ~U[2026-04-21 12:00:30Z]

    {:ok, due_todo} =
      Todos.create_todo(%{title: "Due", estimated_time: ~U[2026-04-21 12:00:10Z]})

    {:ok, other_todo} =
      Todos.create_todo(%{title: "Other", estimated_time: ~U[2026-04-21 12:01:00Z]})

    job = %Job{args: %{"run_at" => DateTime.to_iso8601(run_at)}}

    assert :ok = CompleteDueTodosWorker.perform(job)

    assert Todos.get_todo!(due_todo.id).completed
    refute Todos.get_todo!(other_todo.id).completed
  end
end
