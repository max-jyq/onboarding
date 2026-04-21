defmodule TodoApi.TodosTest do
  use TodoApi.DataCase, async: true

  alias TodoApi.Todos
  alias TodoApi.Todos.Todo

  @valid_attrs %{title: "Learn Phoenix", estimated_time: ~U[2026-04-20 09:00:00Z]}
  @invalid_attrs %{title: nil}

  test "create_todo/1 creates a todo" do
    assert {:ok, %Todo{} = todo} = Todos.create_todo(@valid_attrs)
    assert todo.title == "Learn Phoenix"
    assert todo.estimated_time == ~U[2026-04-20 09:00:00Z]
    refute todo.completed
  end

  test "create_todo/1 returns errors for invalid data" do
    assert {:error, changeset} = Todos.create_todo(@invalid_attrs)
    assert %{title: ["can't be blank"]} = errors_on(changeset)
  end

  test "list_incomplete_todos/0 returns only incomplete todos" do
    {:ok, incomplete_todo} = Todos.create_todo(%{title: "Incomplete"})
    {:ok, completed_todo} = Todos.create_todo(%{title: "Complete", completed: true})

    assert [result] = Todos.list_incomplete_todos()
    assert result.id == incomplete_todo.id
    refute result.id == completed_todo.id
  end

  test "complete_todos_due_now/1 marks only todos in the same minute as complete" do
    now = ~U[2026-04-21 10:30:45Z]

    {:ok, due_a} = Todos.create_todo(%{title: "Due A", estimated_time: ~U[2026-04-21 10:30:00Z]})
    {:ok, due_b} = Todos.create_todo(%{title: "Due B", estimated_time: ~U[2026-04-21 10:30:59Z]})
    {:ok, past} = Todos.create_todo(%{title: "Past", estimated_time: ~U[2026-04-21 10:29:59Z]})

    {:ok, future} =
      Todos.create_todo(%{title: "Future", estimated_time: ~U[2026-04-21 10:31:00Z]})

    {:ok, no_time} = Todos.create_todo(%{title: "No Time"})

    assert {:ok, 2} = Todos.complete_todos_due_now(now)

    assert Todos.get_todo!(due_a.id).completed
    assert Todos.get_todo!(due_b.id).completed
    refute Todos.get_todo!(past.id).completed
    refute Todos.get_todo!(future.id).completed
    refute Todos.get_todo!(no_time.id).completed
  end
end
