defmodule TodoApi.Todos do
  @moduledoc """
  Contains the todo domain logic, including CRUD operations and later any
  todo-specific business rules.
  """

  # Import Ecto.Query for building database queries.
  import Ecto.Query, warn: false

  # Short aliases keep the rest of the module concise.
  alias TodoApi.Repo
  alias TodoApi.Todos.Todo

  @todos_pubsub_topic "todos:events"

  # Return all todos sorted by creation time ascending.
  def list_todos do
    Repo.all(from t in Todo, order_by: [asc: t.inserted_at])
  end

  # Return all incomplete todos sorted by creation time ascending.
  def list_incomplete_todos do
    Repo.all(from t in Todo, where: t.completed == false, order_by: [asc: t.inserted_at])
  end

  # Get a single todo by id.
  # Raises if no record is found.
  def get_todo!(id), do: Repo.get!(Todo, id)

  # Get a single todo by id.
  # Returns nil if no record is found.
  def get_todo(id), do: Repo.get(Todo, id)

  # Create a new todo.
  # attrs is external input and defaults to an empty map.
  def create_todo(attrs \\ %{}) do
    case %Todo{}
         |> Todo.changeset(attrs)
         |> Repo.insert() do
      {:ok, todo} = result ->
        broadcast_todos_changed(:created, %{todo_id: todo.id})
        result

      error ->
        error
    end
  end

  # Update an existing todo.
  # %Todo{} = todo enforces a Todo struct argument.
  def update_todo(%Todo{} = todo, attrs) do
    case todo
         |> Todo.changeset(attrs)
         |> Repo.update() do
      {:ok, updated_todo} = result ->
        broadcast_todos_changed(:updated, %{todo_id: updated_todo.id})
        result

      error ->
        error
    end
  end

  # Delete a todo.
  def delete_todo(%Todo{} = todo) do
    case Repo.delete(todo) do
      {:ok, deleted_todo} = result ->
        broadcast_todos_changed(:deleted, %{todo_id: deleted_todo.id})
        result

      error ->
        error
    end
  end

  # Mark a todo as completed and set completed_at.
  def mark_todo_completed(%Todo{} = todo) do
    update_todo(todo, %{completed: true, completed_at: DateTime.utc_now()})
  end

  # Mark a todo as incomplete only if currently completed, and set estimated_time.
  def mark_todo_incomplete(%Todo{} = todo, estimated_time) do
    if todo.completed do
      update_todo(todo, %{
        completed: false,
        completed_at: nil,
        estimated_time: estimated_time
      })
    else
      {:ok, todo}
    end
  end

  # Return all overdue todos ordered by estimated time ascending.
  def list_overdue_todos do
    now = DateTime.utc_now()

    Repo.all(
      from t in Todo,
        where:
          t.completed == false and
            not is_nil(t.estimated_time) and
            t.estimated_time <= ^now,
        order_by: [asc: t.estimated_time]
    )
  end

  # Build a changeset without writing to the database.
  # Useful for validation or previewing updates.
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  # Mark todos as completed when estimated_time falls within the same minute as now.
  def complete_todos_due_now(now \\ DateTime.utc_now()) do
    # Compare within minute precision: [minute_start, minute_end).
    minute_start = now |> DateTime.truncate(:second) |> then(&%{&1 | second: 0})
    minute_end = DateTime.add(minute_start, 60, :second)
    completed_at = DateTime.truncate(now, :second)

    {updated_count, _} =
      Repo.update_all(
        from(
          t in Todo,
          where:
            t.completed == false and
              not is_nil(t.estimated_time) and
              t.estimated_time >= ^minute_start and
              t.estimated_time < ^minute_end
        ),
        set: [completed: true, completed_at: completed_at]
      )

    if updated_count > 0 do
      broadcast_todos_changed(:completed_due, %{updated_count: updated_count})
    end

    {:ok, updated_count}
  end

  defp broadcast_todos_changed(reason, metadata) do
    Phoenix.PubSub.broadcast(
      TodoApi.PubSub,
      @todos_pubsub_topic,
      {:todos_changed, Map.put(metadata, :reason, reason)}
    )
  end
end
