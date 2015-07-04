defmodule ProjectStatus.ProjectEmailRecipientChannel do
  use ProjectStatus.Web, :channel
  alias ProjectStatus.ProjectEmailing

  def join("project_email_recipients:"<>project_id, payload, socket) do
    if authorized?(payload) do
      {:ok, assign(socket, :project_id, project_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("new_project_email_recipient", email_recipient_params = %{"email" => email, "name" => name}, socket) do
    IO.puts ["new_project_email_recipient", {email, name, socket.assigns[:project_id]}] |> inspect
    case ProjectEmailing.add_recipient_to_project(socket.assigns[:project_id], email_recipient_params) do
      {:ok, email_recipient} -> {:reply, {:ok, %{email_recipient: email_recipient},}, socket}
      {:error, changeset} -> {:reply, {:error, %{changeset: changeset}}, socket}
    end
  end

  def handle_in("delete_project_email_recipient", %{"id" => id}, socket) do
    :ok = ProjectEmailing.delete_email_recipient id
    {:reply, {:ok, %{id: id}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (project_email_recipients:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
