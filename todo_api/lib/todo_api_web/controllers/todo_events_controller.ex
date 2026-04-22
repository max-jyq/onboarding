defmodule TodoApiWeb.TodoEventsController do
  use TodoApiWeb, :controller

  @todos_pubsub_topic "todos:events"

  def stream(conn, _params) do
    Phoenix.PubSub.subscribe(TodoApi.PubSub, @todos_pubsub_topic)

    conn =
      conn
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("x-accel-buffering", "no")
      |> put_resp_content_type("text/event-stream")
      |> send_chunked(200)

    case chunk(conn, "event: connected\ndata: {}\n\n") do
      {:ok, conn} -> stream_loop(conn)
      {:error, :closed} -> conn
    end
  end

  defp stream_loop(conn) do
    receive do
      {:todos_changed, payload} ->
        data = Jason.encode!(payload)

        case chunk(conn, "event: todos_changed\ndata: #{data}\n\n") do
          {:ok, conn} -> stream_loop(conn)
          {:error, :closed} -> conn
        end
    after
      25_000 ->
        case chunk(conn, ": keepalive\n\n") do
          {:ok, conn} -> stream_loop(conn)
          {:error, :closed} -> conn
        end
    end
  end
end
