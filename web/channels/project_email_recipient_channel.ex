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

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("new_project_email_recipient", email_recipient_params = %{"email" => email, "name" => name}, socket) do
    IO.puts ["new_project_email_recipient", {email, name, socket.assigns[:project_id]}] |> inspect
    case ProjectEmailing.add_recipient_to_project(socket.assigns[:project_id], email_recipient_params |> scrub) do
      {:ok, email_recipient} ->
        broadcast socket, "new_project_email_recipient", %{email_recipient: email_recipient}
        {:reply, {:ok, %{email_recipient: email_recipient},}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{changeset: changeset}}, socket}
    end
  end

  def handle_in("delete_project_email_recipient", %{"id" => id}, socket) do
    :ok = ProjectEmailing.delete_email_recipient id
    broadcast socket, "delete_project_email_recipient", %{id: id}
    {:reply, {:ok, %{id: id}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
