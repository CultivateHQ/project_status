defmodule ProjectStatus.ProjectEmailRecipientChannel do
  use ProjectStatus.Web, :channel
  alias ProjectStatus.ProjectEmailing

  # Ok, this may be silly. Use the controller param scrubbing, but don't bothe
  import Phoenix.Controller,  only: [scrub_params: 2]
  defp scrub(params) do
    (scrub_params %{params: %{"c" => params}}, "c")[:params]["c"]
  end

  def join("project_email_recipients:"<>project_id, payload, socket) do
    if authorized?(payload) do
      {:ok, assign(socket, :project_id, project_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("new_project_email_recipient", email_recipient_params = %{"email" => _, "name" => _}, socket) do
    case ProjectEmailing.add_recipient_to_project(socket.assigns[:project_id], email_recipient_params |> scrub) do
      {:ok, email_recipient} ->
        broadcast socket, "new_project_email_recipient", %{email_recipient: email_recipient}
        {:reply, {:ok, %{email_recipient: email_recipient}}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{changeset: changeset}}, socket}
    end
  end

  def handle_in("delete_project_email_recipient", %{"id" => id}, socket) do
    :ok = ProjectEmailing.delete_email_recipient id
    broadcast socket, "delete_project_email_recipient", %{id: id}
    {:reply, {:ok, %{id: id}}, socket}
  end

  def handle_in("project_email_recipients", _, socket) do
    recipients = ProjectEmailing.project_recipients(socket.assigns[:project_id])
    {:reply, {:ok, %{project_email_recipients: recipients}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
