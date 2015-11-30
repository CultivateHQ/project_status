defmodule ProjectStatus.ProjectStatusEmailChannel do
  use ProjectStatus.Web, :channel
  alias ProjectStatus.ProjectEmails

  def join("project_status_emails:"<>project_id, _payload, socket) do
    {:ok, emails_pid} = ProjectEmails.start(project_id)
    {:ok, socket |> assign(:emails_pid, emails_pid)}
  end

  def handle_in("send_status_email", %{"status_date" => status_date, "content" => ""}, socket) do
    handle_in("send_status_email", %{"status_date" => status_date, "content" => nil}, socket)
  end

  def handle_in("send_status_email", %{"status_date" => status_date, "content" => content}, socket) do
    case socket.assigns.emails_pid |>  ProjectEmails.create_status_email(%{
          "status_date" => status_date |> parse_date,
          "content" => content}) do
      {:ok, status_email}  ->
        broadcast socket, "new_status_email", status_email
        {:reply, {:ok, %{status_email: status_email}}, socket}
      {:error, :email_failed} ->
        {:reply, {:email_failed, %{}}, socket}
      {:error, changeset} ->
        {:reply, {:error, %{changeset: changeset}}, socket}
    end
  end

  def handle_in("get_project_status_emails", %{}, socket) do
    status_emails = socket.assigns.emails_pid |> ProjectEmails.project_status_emails
    {:reply, {:ok, %{status_emails: status_emails}}, socket}
  end

  def handle_in("preview_content", %{"markdown" => markdown}, socket) do
    full_markdown = markdown <> ProjectEmails.email_footer(socket.assigns.emails_pid)
    html = full_markdown |> Earmark.to_html
    {:reply, {:ok, %{html: html}}, socket}
  end

  defp parse_date(year_month_day) do
    [year, month, day] = year_month_day
    |> String.split("-")
    |> Enum.map(&(&1 |> String.to_integer))
    %{year: year, month: month, day: day}
  end
end
