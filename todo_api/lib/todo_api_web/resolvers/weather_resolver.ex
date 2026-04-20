defmodule TodoApiWeb.Resolvers.WeatherResolver do
  @moduledoc false

  alias TodoApi.Weather
  alias TodoApi.Weather.WeatherDay
  alias TodoApiWeb.GraphQL.Helpers

  def list_weather_days(_parent, _args, _resolution) do
    {:ok, Enum.map(Weather.list_weather_days(), &serialize_weather_day/1)}
  end

  def get_weather_day(_parent, %{id: id}, _resolution) do
    case Weather.get_weather_day(id) do
      %WeatherDay{} = weather_day -> {:ok, serialize_weather_day(weather_day)}
      nil -> {:error, "Weather record not found."}
    end
  end

  defp serialize_weather_day(weather_day) do
    %{
      id: weather_day.id,
      date: Helpers.encode_date(weather_day.date),
      high_temp: weather_day.high_temp,
      low_temp: weather_day.low_temp,
      inserted_at: Helpers.encode_datetime(weather_day.inserted_at),
      updated_at: Helpers.encode_datetime(weather_day.updated_at)
    }
  end
end
