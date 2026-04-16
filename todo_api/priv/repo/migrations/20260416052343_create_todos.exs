defmodule TodoApi.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string, null: false
      add :estimated_time, :utc_datetime, null: true
      add :completed, :boolean, default: false, null: false
      timestamps()
    end
  end
end
