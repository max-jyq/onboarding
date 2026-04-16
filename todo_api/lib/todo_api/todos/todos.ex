defmodule TodoApi.Todos do
  # warn: false: do not warn if some imported query helpers are unused
  import Ecto.Query, warn: false

  # alias: create an alias for the module
  alias TodoApi.Todos.Todo

  # list: return many items
  # todos: all todo records
  # This function returns all todos ordered by insertion time.
  def list_todos do
    Repo.all(from t in Todo, order_by: [asc: t.inserted_at])
  end

  # get: return one item
  # ! : raise an error if no record is found
  # This function returns one todo by id.
  def get_todo!(id), do: Repo.get!(Todo, id)

  # create: make a new record
  # attrs: attributes / input data
  # \\ %{}: default value is an empty map
  # This function creates a new todo.
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  # update: change an existing record
  # %Todo{} = todo: require the first argument to be a Todo struct
  # This function updates an existing todo.
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  # delete: remove a record from the database
  # This function deletes a todo.
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  # change: build a changeset without saving to the database
  # Useful for validation or form handling
  # This function returns a changeset for a todo.
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
