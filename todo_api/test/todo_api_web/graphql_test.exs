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

  @todo_query """
  query GetTodo($id: ID!) {
    todo(id: $id) {
      id
      title
      estimatedTime
      completed
      completedAt
    }
  }
  """

  @weather_day_query """
  query GetWeatherDay($id: ID!) {
    weatherDay(id: $id) {
      id
      date
      highTemp
      lowTemp
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

  test "fetches a single todo and weather day by id", %{conn: conn} do
    {:ok, todo} =
      Todos.create_todo(%{
        "title" => "Trace a single record",
        "estimated_time" => "2026-04-23T07:45:00Z"
      })

    {:ok, weather_day} =
      Weather.create_weather_day(%{
        "date" => "2026-04-23",
        "high_temp" => 22.3,
        "low_temp" => 11.4
      })

    todo_conn = post_graphql(conn, @todo_query, %{"id" => todo.id})

    assert %{
             "data" => %{
               "todo" => %{
                 "id" => todo_id,
                 "title" => "Trace a single record",
                 "estimatedTime" => "2026-04-23T07:45:00Z",
                 "completed" => false,
                 "completedAt" => nil
               }
             }
           } = json_response(todo_conn, 200)

    assert todo_id == Integer.to_string(todo.id)

    weather_conn = build_conn() |> post_graphql(@weather_day_query, %{"id" => weather_day.id})

    assert %{
             "data" => %{
               "weatherDay" => %{
                 "id" => weather_day_id,
                 "date" => "2026-04-23",
                 "highTemp" => 22.3,
                 "lowTemp" => 11.4
               }
             }
           } = json_response(weather_conn, 200)

    assert weather_day_id == Integer.to_string(weather_day.id)
  end

  test "returns graphql errors for missing records and invalid todo input", %{conn: conn} do
    missing_todo_conn = post_graphql(conn, @todo_query, %{"id" => 999_999})

    assert %{
             "data" => %{"todo" => nil},
             "errors" => [%{"message" => "Todo not found."}]
           } = json_response(missing_todo_conn, 200)

    missing_weather_conn = build_conn() |> post_graphql(@weather_day_query, %{"id" => 999_999})

    assert %{
             "data" => %{"weatherDay" => nil},
             "errors" => [%{"message" => "Weather record not found."}]
           } = json_response(missing_weather_conn, 200)

    invalid_todo_conn =
      build_conn()
      |> post_graphql(@create_todo_mutation, %{
        "input" => %{
          "title" => nil,
          "estimatedTime" => "2026-04-22T09:30:00Z",
          "completed" => false
        }
      })

    assert %{"errors" => [%{"message" => message}]} = json_response(invalid_todo_conn, 200)

    assert message =~ "title"
    assert message =~ "Expected type"
  end

  defp post_graphql(conn, query, variables \\ %{}) do
    conn
    |> put_req_header("accept", "application/json")
    |> post(~p"/api/graphql", %{query: query, variables: variables})
  end
end
