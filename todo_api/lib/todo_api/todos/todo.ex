defmodule TodoApi.Todos.Todo do
  @moduledoc """
  Defines the schema and input validation rules for a single todo record.
  """

  use Ecto.Schema
  import Ecto.Changeset

  # This schema maps to the todos table in the database.
  schema "todos" do
    field :title, :string
    field :estimated_time, :utc_datetime
    field :completed, :boolean, default: false
    field :completed_at, :utc_datetime

    timestamps()
  end

  # Builds a changeset for creating or updating a todo.
  def changeset(todo, attrs) do
    todo
    # Keep only allowed fields from external input and cast to expected types.
    |> cast(attrs, [:title, :estimated_time, :completed, :completed_at])
    |> validate_required([:title])
    |> sync_completed_at()
  end

  defp sync_completed_at(changeset) do
    case get_change(changeset, :completed) do
      true ->
        if is_nil(get_field(changeset, :completed_at)) do
          put_change(changeset, :completed_at, DateTime.utc_now() |> DateTime.truncate(:second))
        else
          changeset
        end

      false ->
        put_change(changeset, :completed_at, nil)

      nil ->
        changeset
    end
  end
end
