defmodule ProjectStatus.ProjectEmails do
  use GenServer
  alias ProjectStatus.Repo
  alias ProjectStatus.StatusEmail
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient

  import Ecto.Query

  ##
  # API
  def start(project_id) do
    {:ok, pid} = Supervisor.start_child(ProjectStatus.ProjectEmailsSupervisor, [project_id])
    Process.link(pid)
    {:ok, pid}
  end

  def create_status_email(pid, email_params) do
    pid |> GenServer.call({:create_status_email, email_params})
  end

  def project_status_emails(pid) do
    pid |> GenServer.call(:project_status_emails)
  end

  def project_status_email(pid, email_id) do
    pid |> GenServer.call({:project_status_email, email_id})
  end

  def email_footer(pid) do
    pid |> GenServer.call(:email_footer)
  end

  def start_link(project_id) do
    GenServer.start_link(__MODULE__, project_id)
  end

  ##
  # Callback
  def init(state) do
    {:ok, state}
  end

  def handle_call({:create_status_email, email_params}, _from, project_id) do
    reply = do_create_status_email(project_id, email_params)
    {:reply, reply, project_id}
  end

  def handle_call(:project_status_emails, _from, project_id) do
    emails = (from e in StatusEmail,
              where: e.project_id == ^project_id,
              order_by: [asc: e.status_date]) |> Repo.all
    {:reply, emails, project_id}
  end

  def handle_call({:project_status_email, email_id}, _from, project_id) do
    reply = do_project_status_email(project_id, email_id)
    {:reply, reply, project_id}
  end

  def handle_call(:email_footer, _from, project_id) do
    {:reply, get_email_footer(project_id), project_id}
  end

  def do_project_status_email(project_id, email_id) do
    case (from e in StatusEmail,
          where: e.id == ^email_id
          and e.project_id == ^project_id) |> Repo.one do
      nil -> {:error, :not_found}
      email -> {:ok, email}
    end
  end


  defp do_create_status_email(project_id, %{"status_date" => status_date, "content" => content}) do
    subject = "Status update - #{project_name(project_id)} - #{format_date(status_date)}"
    attributes = %{"project_id" => project_id,
                   "subject" => subject,
                   "content" => content,
                   "status_date" => status_date}
    changeset = StatusEmail.changeset(%StatusEmail{}, attributes)
    if changeset.valid? do
      case send_email(project_id, attributes) do
        {:ok, _} -> {:ok, changeset |> Repo.insert!}
        _ -> {:error, :email_failed}
      end
    else
      {:error, changeset}
    end
  end

  defp get_email_footer(project_id) do
    case (from p in Project, where: p.id == ^project_id, select: p.email_footer)
    |> Repo.one do
      nil -> ""
      footer -> "\n\n" <> footer
    end
  end

  defp project_name(project_id) do
    (from p in Project, where: p.id == ^project_id, select: p.name) |> Repo.one
  end

  defp format_date(%{year: year, month: month, day: day}) do
    Chronos.Formatter.strftime({year, month, day}, "%Y-%0m-%0d")
  end

  defp send_email(project_id, email_attributes) do
    content = email_attributes["content"] <> get_email_footer(project_id)
    ProjectStatus.Mailing.Mailer.send recipients_as_string(project_id), email_attributes["subject"], content
  end

  defp recipients_as_string(project_id) do
    (from r in EmailRecipient, select: [r.name, r.email], where: r.project_id == ^project_id)
    |> Repo.all
    |> Enum.map(fn [name, email] -> "#{name} <#{email}>" end)
    |> Enum.join(",")
  end
end
