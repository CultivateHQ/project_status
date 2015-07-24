defmodule ProjectStatus.StatusEmailController do
  use ProjectStatus.Web, :controller
  alias ProjectStatus.ProjectEmailing

  plug :action

  def show(conn, params) do
    IO.puts params |> inspect
    {:ok, status_email} = ProjectEmailing.project_status_email(params["project_id"], params["id"])
    render(conn, "show.html", %{status_email: status_email, project_id: params["project_id"]})
  end
end
