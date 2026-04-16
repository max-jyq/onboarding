defmodule TodoApi.Weather.WeatherDay do
  use Ecto.Schema
  import Ecto.Changeset

  # This schema maps to the weather_days table in the database.
  schema "weather_days" do
    field :date, :date
    field :high_temp, :float
    field :low_temp, :float

    timestamps()
  end

  def changeset(weather_day, attrs) do
    weather_day
    |> cast(attrs, [:date, :high_temp, :low_temp])
    |> validate_required([:date, :high_temp, :low_temp])
    |> unique_constraint(:date) # Ensure one entry per date
  end
end
