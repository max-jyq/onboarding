defmodule TodoApi.Weather.WeatherDay do
  @moduledoc """
  Defines the schema and validation rules for one stored weather day record.
  """

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
    # Ensure one entry per date
    |> unique_constraint(:date)
  end
end
