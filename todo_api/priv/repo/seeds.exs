# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TodoApi.Repo.insert!(%TodoApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TodoApi.Repo
alias TodoApi.Todos.Todo

todo_seed_data = [
  # Today (2026-04-21)
  %{title: "Morning standup prep", estimated_time: ~U[2026-04-21 08:30:00Z], completed: false},
  %{title: "Reply emails", estimated_time: ~U[2026-04-21 09:00:30Z], completed: false},
  %{title: "Team sync notes", estimated_time: ~U[2026-04-21 10:15:00Z], completed: false},
  %{
    title: "Pay phone bill",
    estimated_time: ~U[2026-04-21 11:59:59Z],
    completed: true,
    completed_at: ~U[2026-04-21 12:00:02Z]
  },
  %{title: "Lunch order", estimated_time: ~U[2026-04-21 12:00:10Z], completed: false},
  %{title: "Refactor worker code", estimated_time: ~U[2026-04-21 14:45:00Z], completed: false},
  %{title: "Push git commit", estimated_time: ~U[2026-04-21 16:30:00Z], completed: false},
  %{title: "Read Oban docs", estimated_time: nil, completed: false},

  # Tomorrow (2026-04-22)
  %{title: "Plan tomorrow tasks", estimated_time: ~U[2026-04-22 07:45:00Z], completed: false},
  %{title: "Daily journal", estimated_time: ~U[2026-04-22 08:00:00Z], completed: false},
  %{title: "Design review", estimated_time: ~U[2026-04-22 09:30:00Z], completed: false},
  %{title: "Fix flaky test", estimated_time: ~U[2026-04-22 10:00:30Z], completed: false},
  %{title: "Grocery list", estimated_time: ~U[2026-04-22 12:15:00Z], completed: false},
  %{title: "Run 5km", estimated_time: ~U[2026-04-22 17:45:00Z], completed: false},
  %{title: "Call parents", estimated_time: ~U[2026-04-22 20:00:00Z], completed: false},
  %{title: "Backup laptop", estimated_time: nil, completed: false}
]

Enum.each(todo_seed_data, fn attrs ->
  %Todo{}
  |> Todo.changeset(attrs)
  |> Repo.insert!()
end)
