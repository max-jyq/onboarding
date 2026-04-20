defmodule TodoApi.Weather do
  @moduledoc """
  Contains the weather domain logic for storing and querying daily weather data.
  """

  import Ecto.Query, warn: false

  alias TodoApi.Repo
  alias TodoApi.Weather.WeatherDay

  def list_weather_days do
    Repo.all(from w in WeatherDay, order_by: [asc: w.date])
  end

  def get_weather_day!(id), do: Repo.get!(WeatherDay, id)

  def get_weather_day(id), do: Repo.get(WeatherDay, id)

  def get_weather_day_by_date(date), do: Repo.get_by(WeatherDay, date: date)

  def create_weather_day(attrs \\ %{}) do
    %WeatherDay{}
    |> WeatherDay.changeset(attrs)
    |> Repo.insert()
  end

  def update_weather_day(%WeatherDay{} = weather_day, attrs) do
    weather_day
    |> WeatherDay.changeset(attrs)
    |> Repo.update()
  end

  def delete_weather_day(%WeatherDay{} = weather_day) do
    Repo.delete(weather_day)
  end

  def change_weather_day(%WeatherDay{} = weather_day, attrs \\ %{}) do
    WeatherDay.changeset(weather_day, attrs)
  end
end
