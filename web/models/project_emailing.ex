defmodule ProjectStatus.ProjectEmailing do
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient
  alias ProjectStatus.StatusEmail
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

  def create_status_email(%Project{id: project_id}, params) do
    create_status_email(project_id, params)
  end

  def create_status_email(project_id, params = %{"status_date" => status_date}) do
    subject = "Status update - #{project_name(project_id)} - #{format_date(status_date)}"
    changeset = StatusEmail.changeset(%StatusEmail{}, params
                                      |> Map.merge(%{ "project_id" => project_id,
                                                      "subject" => subject}))
   if changeset.valid? do
     {:ok, changeset |> Repo.insert!}
   else
     {:error, changeset}
   end
  end

  def project_status_emails(%Project{id: project_id}) do
    project_status_emails project_id
  end

  def project_status_emails(project_id) do
    (from e in StatusEmail, where: e.project_id == ^project_id, order_by: [asc: e.status_date]) |> Repo.all
  end

  def project_status_email(%Project{id: project_id}, id) do
    project_status_email project_id, id
  end

  def project_status_email(project_id, id) do
    case (from e in StatusEmail, where: e.id == ^id and e.project_id == ^project_id) |> Repo.one do
      nil -> :not_found
      email -> {:ok, email}
    end
  end

  defp project_name(project_id) do
    (from p in Project, where: p.id == ^project_id, select: p.name) |> Repo.one
  end

  defp format_date(%{year: year, month: month, day: day}) do
    Chronos.Formatter.strftime({year, month, day}, "%Y-%0m-%0d")
  end
end

