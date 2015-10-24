defmodule ProjectStatus.ProjectRecipients do
  use GenServer

  # alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient
  # alias ProjectStatus.StatusEmail
  alias ProjectStatus.Repo

  import Ecto.Query

  ##
  # API
  def start(project_id) do
    {:ok, pid} = Supervisor.start_child(ProjectStatus.ProjectRecipientsSupervisor, [self, project_id])
    Process.link(pid)
    {:ok, pid}
  end

  def add_recipient_to_project(pid, recipient) do
    GenServer.call(pid, {:add_recipient_to_project, recipient})
  end

  def delete_recipient(pid, recipient_id) do
    GenServer.call(pid, {:delete_recipient, recipient_id})
  end

  def project_recipients(pid) do
    GenServer.call(pid, :project_recipients)
  end

  ##
  # Lifecycle
  def start_link(client_pid, project_id) do
    GenServer.start_link(__MODULE__, {client_pid, project_id})
  end

  def init({_,_} = state) do
    {:ok, state}
  end

  ##
  # Callbacks
  def handle_call({:add_recipient_to_project, recipient_params}, _from, {_, project_id} = state) do
    recipient = recipient_params
    |> Map.put("project_id", project_id)
    |> add_recipient
    {:reply, recipient, state}
  end

  def handle_call({:delete_recipient, recipient_id}, _from, state) do
    Repo.get(EmailRecipient, recipient_id) |> Repo.delete!
    {:reply, :ok, state}
  end

  def handle_call(:project_recipients, _from, {_, project_id} = state) do
    recipients = (from r in EmailRecipient, where: r.project_id == ^project_id)
    |> Repo.all
    {:reply, {:ok, recipients}, state}
  end

  # private
  defp add_recipient(params) do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, params)
    if changeset.valid? do
      changeset |> Repo.insert
    else
      {:error, changeset}
    end
  end
end
