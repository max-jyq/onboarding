defmodule TodoApiWeb.PageController do
  use TodoApiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
