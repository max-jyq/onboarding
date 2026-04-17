defmodule TodoApi.Repo.Migrations.CreateWeatherDays do
  use Ecto.Migration

  def change do
    create table(:weather_days) do
      add :date, :date, null: false
      add :high_temp, :float, null: false
      add :low_temp, :float, null: false
      timestamps()
    end

    # Ensure one entry per date
    create unique_index(:weather_days, [:date])
  end
end
