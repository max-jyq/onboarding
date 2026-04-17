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
    |> cast(attrs, [:title, :estimated_time, :completed, :completed_at]) #从外部数据里挑出允许的字段，并尝试转换成正确类型
    |> validate_required([:title])
  end
end
