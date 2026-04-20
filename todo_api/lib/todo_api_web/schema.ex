defmodule TodoApiWeb.Schema do
  use Absinthe.Schema

  alias TodoApiWeb.Resolvers

  query do
    field :todos, non_null(list_of(non_null(:todo))) do
      resolve(&Resolvers.TodoResolver.list_todos/3)
    end

    field :todo, :todo do
      arg(:id, non_null(:id))
      resolve(&Resolvers.TodoResolver.get_todo/3)
    end

    field :weather_days, non_null(list_of(non_null(:weather_day))) do
      resolve(&Resolvers.WeatherResolver.list_weather_days/3)
    end

    field :weather_day, :weather_day do
      arg(:id, non_null(:id))
      resolve(&Resolvers.WeatherResolver.get_weather_day/3)
    end
  end

  mutation do
    field :create_todo, :todo do
      arg(:input, non_null(:todo_input))
      resolve(&Resolvers.TodoResolver.create_todo/3)
    end

    field :update_todo, :todo do
      arg(:id, non_null(:id))
      arg(:input, non_null(:todo_input))
      resolve(&Resolvers.TodoResolver.update_todo/3)
    end

    field :delete_todo, non_null(:boolean) do
      arg(:id, non_null(:id))
      resolve(&Resolvers.TodoResolver.delete_todo/3)
    end
  end

  input_object :todo_input do
    field :title, non_null(:string)
    field :estimated_time, :string
    field :completed, :boolean
  end

  object :todo do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :estimated_time, :string
    field :completed, non_null(:boolean)
    field :completed_at, :string
    field :inserted_at, :string
    field :updated_at, :string
  end

  object :weather_day do
    field :id, non_null(:id)
    field :date, non_null(:string)
    field :high_temp, non_null(:float)
    field :low_temp, non_null(:float)
    field :inserted_at, :string
    field :updated_at, :string
  end
end
