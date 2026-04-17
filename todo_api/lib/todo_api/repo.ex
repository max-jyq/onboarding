defmodule TodoApi.Repo do
  @moduledoc """
  Handles database access for the backend through Ecto.
  """

  use Ecto.Repo,
    otp_app: :todo_api,
    adapter: Ecto.Adapters.Postgres
end
