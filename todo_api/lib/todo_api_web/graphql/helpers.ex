defmodule TodoApiWeb.GraphQL.Helpers do
  @moduledoc false

  def encode_datetime(nil), do: nil
  def encode_datetime(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
  def encode_datetime(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_iso8601(datetime)

  def encode_date(nil), do: nil
  def encode_date(%Date{} = date), do: Date.to_iso8601(date)

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
