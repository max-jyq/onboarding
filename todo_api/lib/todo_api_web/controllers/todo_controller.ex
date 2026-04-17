defmodule TodoApiWeb.TodoController do
  use TodoApiWeb, :controller

  alias TodoApi.Todos
  alias TodoApi.Todos.Todo

  def index(conn, _params) do
    todos = Todos.list_todos()

    json(conn, %{data: Enum.map(todos, &todo_data/1)})
  end

  def show(conn, %{"id" => id}) do
    case Todos.get_todo(id) do
      %Todo{} = todo ->
        json(conn, %{data: todo_data(todo)})

      nil ->
        send_not_found(conn)
    end
  end

  def create(conn, %{"todo" => todo_params}) do
    case Todos.create_todo(todo_params) do
      {:ok, todo} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/todos/#{todo.id}")
        |> json(%{data: todo_data(todo)})

      {:error, changeset} ->
        send_changeset_errors(conn, changeset)
    end
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    case Todos.get_todo(id) do
      %Todo{} = todo ->
        case Todos.update_todo(todo, todo_params) do
          {:ok, updated_todo} ->
            json(conn, %{data: todo_data(updated_todo)})

          {:error, changeset} ->
            send_changeset_errors(conn, changeset)
        end

      nil ->
        send_not_found(conn)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Todos.get_todo(id) do
      %Todo{} = todo ->
        {:ok, _todo} = Todos.delete_todo(todo)
        send_resp(conn, :no_content, "")

      nil ->
        send_not_found(conn)
    end
  end

  defp send_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{detail: "Not Found"}})
  end

  defp send_changeset_errors(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: translate_errors(changeset)})
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  defp todo_data(todo) do
    %{
      id: todo.id,
      title: todo.title,
      estimated_time: encode_datetime(todo.estimated_time),
      completed: todo.completed,
      completed_at: encode_datetime(todo.completed_at),
      inserted_at: encode_datetime(todo.inserted_at),
      updated_at: encode_datetime(todo.updated_at)
    }
  end

  defp encode_datetime(nil), do: nil
  defp encode_datetime(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
  defp encode_datetime(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)
end
