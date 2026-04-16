defmodule TodoApi.Repo.Migrations.AddCompletedAtToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add(:completed_at, :utc_datetime)
    end
  end
end
