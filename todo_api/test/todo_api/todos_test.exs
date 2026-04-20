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
end
