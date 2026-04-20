defmodule TodoApiWeb.GraphQLTest do
  use TodoApiWeb.ConnCase, async: true

  alias TodoApi.Todos
  alias TodoApi.Weather

  @create_todo_mutation """
  mutation CreateTodo($input: TodoInput!) {
    createTodo(input: $input) {
      id
      title
      estimatedTime
      completed
      completedAt
    }
  }
  """

  @update_todo_mutation """
  mutation UpdateTodo($id: ID!, $input: TodoInput!) {
    updateTodo(id: $id, input: $input) {
      id
      title
      estimatedTime
      completed
      completedAt
    }
  }
  """

  test "queries todos and weather days", %{conn: conn} do
    {:ok, todo} =
      Todos.create_todo(%{
        "title" => "Learn GraphQL",
        "estimated_time" => "2026-04-21T08:00:00Z"
      })

    {:ok, weather_day} =
      Weather.create_weather_day(%{
        "date" => "2026-04-21",
        "high_temp" => 28.5,
        "low_temp" => 16.2
      })

    conn =
      post_graphql(conn, """
      query DashboardData {
        todos {
          id
          title
          estimatedTime
          completed
        }
        weatherDays {
          id
          date
          highTemp
          lowTemp
        }
      }
      """)

    assert %{
             "data" => %{
               "todos" => [
                 %{
                   "id" => todo_id,
                   "title" => "Learn GraphQL",
                   "estimatedTime" => "2026-04-21T08:00:00Z",
                   "completed" => false
                  }
               ],
               "weatherDays" => [
                 %{
                   "id" => weather_day_id,
                   "date" => "2026-04-21",
                   "highTemp" => 28.5,
                   "lowTemp" => 16.2
                 }
               ]
             }
           } = json_response(conn, 200)

    assert todo_id == Integer.to_string(todo.id)
    assert weather_day_id == Integer.to_string(weather_day.id)
  end

  test "creates, updates, and deletes a todo through mutations", %{conn: conn} do
    conn =
      post_graphql(conn, @create_todo_mutation, %{
        "input" => %{
          "title" => "Ship GraphQL endpoint",
          "estimatedTime" => "2026-04-22T09:30:00Z",
          "completed" => false
        }
      })

    assert %{
             "data" => %{
               "createTodo" => %{
                 "id" => id,
                 "title" => "Ship GraphQL endpoint",
                 "estimatedTime" => "2026-04-22T09:30:00Z",
                 "completed" => false,
                 "completedAt" => nil
               }
             }
           } = json_response(conn, 200)

    conn =
      build_conn()
      |> post_graphql(@update_todo_mutation, %{
        "id" => id,
        "input" => %{
          "title" => "Ship GraphQL endpoint",
          "estimatedTime" => "2026-04-22T09:30:00Z",
          "completed" => true
        }
      })

    assert %{
             "data" => %{
               "updateTodo" => %{
                 "id" => ^id,
                 "completed" => true,
                 "completedAt" => completed_at
               }
             }
           } = json_response(conn, 200)

    assert is_binary(completed_at)

    conn =
      build_conn()
      |> post_graphql(
        """
        mutation DeleteTodo($id: ID!) {
          deleteTodo(id: $id)
        }
        """,
        %{"id" => id}
      )

    assert %{"data" => %{"deleteTodo" => true}} = json_response(conn, 200)
  end

  defp post_graphql(conn, query, variables \\ %{}) do
    conn
    |> put_req_header("accept", "application/json")
    |> post(~p"/api/graphql", %{query: query, variables: variables})
  end
end
