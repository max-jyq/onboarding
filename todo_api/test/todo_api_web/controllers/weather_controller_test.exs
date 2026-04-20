defmodule TodoApiWeb.WeatherControllerTest do
  use TodoApiWeb.ConnCase, async: true

  alias TodoApi.Weather

  test "lists weather days", %{conn: conn} do
    {:ok, weather_day} =
      Weather.create_weather_day(%{date: ~D[2026-04-20], high_temp: 24.5, low_temp: 13.2})

    weather_day_id = weather_day.id

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> get(~p"/api/weather")

    assert %{
             "data" => [
               %{
                 "id" => ^weather_day_id,
                 "date" => "2026-04-20",
                 "high_temp" => 24.5,
                 "low_temp" => 13.2
               }
             ]
           } = json_response(conn, 200)
  end

  test "shows weather day", %{conn: conn} do
    {:ok, weather_day} =
      Weather.create_weather_day(%{date: ~D[2026-04-20], high_temp: 24.5, low_temp: 13.2})

    weather_day_id = weather_day.id

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> get(~p"/api/weather/#{weather_day.id}")

    assert %{
             "data" => %{
               "id" => ^weather_day_id,
               "date" => "2026-04-20",
               "high_temp" => 24.5,
               "low_temp" => 13.2
             }
           } = json_response(conn, 200)
  end

  test "returns not found for missing weather day", %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> get(~p"/api/weather/999999")

    assert %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
  end
end
