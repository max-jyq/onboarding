defmodule TodoApiWeb.Resolvers.TodoResolver do
  @moduledoc false

  alias TodoApi.Todos
  alias TodoApi.Todos.Todo
  alias TodoApiWeb.GraphQL.Helpers

  def list_todos(_parent, _args, _resolution) do
    {:ok, Enum.map(Todos.list_todos(), &serialize_todo/1)}
  end

  def get_todo(_parent, %{id: id}, _resolution) do
    case Todos.get_todo(id) do
      %Todo{} = todo -> {:ok, serialize_todo(todo)}
      nil -> {:error, "Todo not found."}
    end
  end

  def create_todo(_parent, %{input: attrs}, _resolution) do
    case Todos.create_todo(attrs) do
      {:ok, todo} -> {:ok, serialize_todo(todo)}
      {:error, changeset} -> {:error, format_changeset_errors(changeset)}
    end
  end

  def update_todo(_parent, %{id: id, input: attrs}, _resolution) do
    case Todos.get_todo(id) do
      %Todo{} = todo ->
        case Todos.update_todo(todo, attrs) do
          {:ok, updated_todo} -> {:ok, serialize_todo(updated_todo)}
          {:error, changeset} -> {:error, format_changeset_errors(changeset)}
        end

      nil ->
        {:error, "Todo not found."}
    end
  end

  def delete_todo(_parent, %{id: id}, _resolution) do
    case Todos.get_todo(id) do
      %Todo{} = todo ->
        case Todos.delete_todo(todo) do
          {:ok, _todo} -> {:ok, true}
          {:error, changeset} -> {:error, format_changeset_errors(changeset)}
        end

      nil ->
        {:error, "Todo not found."}
    end
  end

  defp serialize_todo(todo) do
    %{
      id: todo.id,
      title: todo.title,
      estimated_time: Helpers.encode_datetime(todo.estimated_time),
      completed: todo.completed,
      completed_at: Helpers.encode_datetime(todo.completed_at),
      inserted_at: Helpers.encode_datetime(todo.inserted_at),
      updated_at: Helpers.encode_datetime(todo.updated_at)
    }
  end

  defp format_changeset_errors(changeset) do
    changeset
    |> Helpers.translate_errors()
    |> Enum.map(fn {field, messages} -> "#{field} #{Enum.join(messages, ", ")}" end)
    |> Enum.join("; ")
  end
end
