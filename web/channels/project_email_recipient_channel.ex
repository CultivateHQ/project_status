defmodule ProjectStatus.ProjectEmailRecipientChannel do
  use ProjectStatus.Web, :channel
  alias ProjectStatus.ProjectRecipients

  # Ok, this may be silly. Use the controller param scrubbing, but don't bothe
  import Phoenix.Controller,  only: [scrub_params: 2]
  defp scrub(params) do
    (scrub_params %{params: %{"c" => params}}, "c")[:params]["c"]
  end

  def join("project_email_recipients:"<>project_id, _payload, socket) do
    {:ok, recipients_pid} = ProjectRecipients.start(project_id)
    {:ok, socket
     |> assign(:recipients_pid, recipients_pid)}
  end

  def handle_in("new_project_email_recipient", email_recipient_params = %{"email" => _, "name" => _}, socket) do
    case socket.assigns.recipients_pid |> ProjectRecipients.add_recipient_to_project(email_recipient_params |> scrub) do
      {:ok, email_recipient} ->
        broadcast socket, "new_project_email_recipient", %{email_recipient: email_recipient}
        {:reply, {:ok, %{email_recipient: email_recipient}}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{changeset: changeset}}, socket}
    end
  end

  def handle_in("delete_project_email_recipient", %{"id" => id}, socket) do
    :ok = socket.assigns.recipients_pid |>  ProjectRecipients.delete_recipient(id)
    broadcast socket, "delete_project_email_recipient", %{id: id}
    {:reply, {:ok, %{id: id}}, socket}
  end

  def handle_in("project_email_recipients", _, socket) do
    {:ok, recipients} = socket.assigns.recipients_pid |> ProjectRecipients.project_recipients
    {:reply, {:ok, %{project_email_recipients: recipients}}, socket}
  end
end
