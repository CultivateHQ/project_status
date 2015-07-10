defmodule ProjectStatus.ProjectStatusEmailChannel do
  use ProjectStatus.Web, :channel
  alias ProjectStatus.ProjectEmailing

  def join("project_status_emails:"<>project_id, payload, socket) do
    if authorized?(payload) do
      {:ok, assign(socket, :project_id, project_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("send_status_email", %{"status_date" => status_date, "content" => ""}, socket) do
    handle_in("send_status_email", %{"status_date" => status_date, "content" => nil}, socket)
  end

  def handle_in("send_status_email", %{"status_date" => status_date, "content" => content}, socket) do
    case ProjectEmailing.create_status_email(socket.assigns[:project_id],
                                             %{"status_date" => status_date |> parse_date,
                                               "content" => content}) do
      {:ok, status_email}  ->
        broadcast socket, "new_status_email", status_email
        {:reply, {:ok, %{status_email: status_email}}, socket}
      {:error, changeset} ->
        {:reply, {:error, %{changeset: changeset}}, socket}
    end
  end

  def handle_in("get_project_status_emails", %{}, socket) do
    status_emails = socket.assigns[:project_id] |> ProjectEmailing.project_status_emails
    {:reply, {:ok, %{status_emails: status_emails}}, socket}
  end

  defp parse_date(year_month_day) do
    [year, month, day] = year_month_day
    |> String.split("-")
    |> Enum.map(&(&1 |> String.to_integer))
    %{year: year, month: month, day: day}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
