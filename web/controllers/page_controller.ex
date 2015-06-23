defmodule ProjectStatus.PageController do
  use ProjectStatus.Web, :controller

  plug :action

  def index(conn, _params) do
    conn |> redirect(to: project_path(conn, :index))
  end
end
