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
    changeset = EmailRecipient.changeset(fix_meta_source(%EmailRecipient{}), params)
    if changeset.valid? do
      changeset |> Repo.insert
    else
      {:error, changeset}
    end
  end

  ##
  # Encountering a weird problem where %EmailRecipient.__meta__source is `"email_recipients" `
  # not `{nil, "email_recipients}` on a fresh compile. It happens consistently in the same place,
  # such as always in this file, but without any discernable pattern in the code
  # ¯\_(ツ)_/¯	
  defp fix_meta_source(r = %EmailRecipient{__meta__: %{source: {_, _}}}) do
    r
  end

  defp fix_meta_source(r = %EmailRecipient{__meta__: meta = %{source: source}}) do
    fixed_meta = meta |> Map.put(:source, {nil, source})
    r |> Map.put(:__meta__, fixed_meta)
  end
end
