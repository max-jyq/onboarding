defmodule TodoApiWeb.TodoControllerTest do
  use TodoApiWeb.ConnCase, async: true

  alias TodoApi.Todos

  @create_attrs %{
    "title" => "Write onboarding task",
    "estimated_time" => "2026-04-18T10:30:00Z"
  }
  @update_attrs %{
    "title" => "Ship manual todo API",
    "estimated_time" => "2026-04-19T09:15:00Z",
    "completed" => true
  }
  @invalid_attrs %{"title" => nil}

  test "lists todos", %{conn: conn} do
    {:ok, todo} = Todos.create_todo(@create_attrs)
    todo_id = todo.id

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> get(~p"/api/todos")

    assert %{
             "data" => [
               %{
                 "id" => ^todo_id,
                 "title" => "Write onboarding task",
                 "estimated_time" => "2026-04-18T10:30:00Z",
                 "completed" => false,
                 "completed_at" => nil
               }
             ]
           } = json_response(conn, 200)
  end

  test "creates todo", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> post(~p"/api/todos", todo: @create_attrs)

    assert %{
             "data" => %{
               "id" => id,
               "title" => "Write onboarding task",
               "estimated_time" => "2026-04-18T10:30:00Z",
               "completed" => false,
               "completed_at" => nil
             }
           } = json_response(conn, 201)

    assert get_resp_header(conn, "location") == ["/api/todos/#{id}"]
  end

  test "shows todo", %{conn: conn} do
    {:ok, todo} = Todos.create_todo(@create_attrs)
    todo_id = todo.id

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> get(~p"/api/todos/#{todo.id}")

    assert %{
             "data" => %{
               "id" => ^todo_id,
               "title" => "Write onboarding task",
               "estimated_time" => "2026-04-18T10:30:00Z",
               "completed" => false,
               "completed_at" => nil
             }
           } = json_response(conn, 200)
  end

  test "updates todo", %{conn: conn} do
    {:ok, todo} = Todos.create_todo(@create_attrs)
    todo_id = todo.id

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put(~p"/api/todos/#{todo.id}", todo: @update_attrs)

    assert %{
             "data" => %{
               "id" => ^todo_id,
               "title" => "Ship manual todo API",
               "estimated_time" => "2026-04-19T09:15:00Z",
               "completed" => true,
               "completed_at" => completed_at
             }
           } = json_response(conn, 200)

    assert is_binary(completed_at)
  end

  test "deletes todo", %{conn: conn} do
    {:ok, todo} = Todos.create_todo(@create_attrs)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> delete(~p"/api/todos/#{todo.id}")

    response(conn, 204)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> get(~p"/api/todos/#{todo.id}")

    assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
  end

  test "returns validation errors when create fails", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> post(~p"/api/todos", todo: @invalid_attrs)

    assert %{"errors" => %{"title" => [_message]}} = json_response(conn, 422)
  end
end
