defmodule TodoApiWeb.WeatherController do
  use TodoApiWeb, :controller

  alias TodoApi.Weather
  alias TodoApi.Weather.WeatherDay

  def index(conn, _params) do
    weather_days = Weather.list_weather_days()

    json(conn, %{data: Enum.map(weather_days, &weather_day_data/1)})
  end

  def show(conn, %{"id" => id}) do
    case Weather.get_weather_day(id) do
      %WeatherDay{} = weather_day ->
        json(conn, %{data: weather_day_data(weather_day)})

      nil ->
        send_not_found(conn)
    end
  end

  defp send_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{detail: "Not Found"}})
  end

  defp weather_day_data(weather_day) do
    %{
      id: weather_day.id,
      date: encode_date(weather_day.date),
      high_temp: weather_day.high_temp,
      low_temp: weather_day.low_temp,
      inserted_at: encode_datetime(weather_day.inserted_at),
      updated_at: encode_datetime(weather_day.updated_at)
    }
  end

  defp encode_date(nil), do: nil
  defp encode_date(%Date{} = date), do: Date.to_iso8601(date)

  defp encode_datetime(nil), do: nil
  defp encode_datetime(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
  defp encode_datetime(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)
end
