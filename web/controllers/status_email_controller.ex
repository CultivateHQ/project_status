defmodule ProjectStatus.StatusEmailController do
  use ProjectStatus.Web, :controller
  alias ProjectStatus.ProjectEmails
  alias ProjectStatus.Project

  def show(conn, params) do
    {:ok, status_email} = ProjectEmails.do_project_status_email(params["project_id"], params["id"])

    project = Repo.get(Project, params["project_id"])
    render(conn, "show.html", %{status_email: status_email, project: project, project_id: params["project_id"]})
  end
end
