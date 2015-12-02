defmodule ProjectStatus.ProjectController do
  use ProjectStatus.Web, :controller

  alias ProjectStatus.Project

  plug :scrub_params, "project" when action in [:create, :update]

  def index(conn, _params) do
    projects = Repo.all(Project)
    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    changeset = Project.changeset(%Project{}, project_params)

    if changeset.valid? do
      Repo.insert!(changeset) 
      conn
      |> put_flash(:info, "Project created successfully.")
      |> redirect(to: project_path(conn, :index))
    else
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    project = Repo.get(Project, id)
    # TEMP
    if project.trello_project_id do
      trello_totals = case Trello.sum_points_for_board(project.trello_project_id) do
                        {:ok, totals} -> totals
                        _ -> nil
                      end
    end
    render(conn, "show.html", project: project, trello_totals: trello_totals)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get(Project, id)
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get(Project, id)
    changeset = Project.changeset(project, project_params)

    if changeset.valid? do
      Repo.update!(changeset)

      conn
      |> put_flash(:info, "Project updated successfully.")
      |> redirect(to: project_path(conn, :index))
    else
      render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get(Project, id)
    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: project_path(conn, :index))
  end
end
