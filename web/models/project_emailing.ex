defmodule ProjectStatus.ProjectEmailing do
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient
  alias ProjectStatus.Repo

  import Ecto.Query

  def add_recipient_to_project(%Project{id: project_id}, params) do
    add_recipient_to_project project_id, params
  end

  def add_recipient_to_project(project_id, params) do
    add_recipient params |> Map.put("project_id", project_id)
  end

  def delete_email_recipient(%EmailRecipient{id: id}) do
    delete_email_recipient id
  end

  def delete_email_recipient id do
    Repo.get(EmailRecipient, id) |> Repo.delete!
    :ok
  end

  def project_recipients(%Project{id: project_id}) do
    project_recipients project_id
  end

  def project_recipients project_id do
    (from r in EmailRecipient, where: r.project_id == ^project_id)
      |> Repo.all
  end

  defp add_recipient(params) do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, params)
    if changeset.valid? do
      {:ok, changeset |> Repo.insert!}
    else
      {:error, changeset}
    end
  end
end

