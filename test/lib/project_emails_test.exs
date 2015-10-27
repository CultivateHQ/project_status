defmodule ProjectEmailsTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.Project
  alias ProjectStatus.StatusEmail
  alias ProjectStatus.EmailRecipient
  alias ProjectStatus.ProjectEmails


  setup do
    DummyMailer.start_link
    project = create_project
    {:ok, pid} = ProjectEmails.start(project.id)
    {:ok, %{project: project, pid: pid}}
  end


  test "creating a valid status email", %{project: project, pid: pid} do
    assert {:ok, status_email} = pid |>
      ProjectEmails.create_status_email(%{"status_date" => %{year: 2015, month: 3, day: 9}, "content" => "Stuff happened"})
    assert [status_email] = (project |> Repo.preload(:status_emails)).status_emails
    assert status_email.status_date |> Ecto.Date.to_erl == {2015, 3, 9}
    assert status_email.subject == "Status update - A project - 2015-03-09"
    assert status_email.content == "Stuff happened"
    assert [{"Mavis <mavis@example.com>,Sue <sue@example.com>",
             "Status update - A project - 2015-03-09", "Stuff happened"}] == DummyMailer.emails_sent
  end

  test "email failed to send", %{pid: pid} do
    DummyMailer.set_emailing_result(:error)
    {:error, :email_failed} = pid |>
      ProjectEmails.create_status_email(%{"status_date" => %{year: 2015, month: 3, day: 9}, "content" => "Stuff happened"})
    assert 0 == (from e in StatusEmail, select: count(e.id)) |> Repo.one
  end

  test "email fails validation", %{pid: pid} do
    {:error, _changeset} = pid
    |> ProjectEmails.create_status_email(%{"status_date" => %{year: 2015, month: 1, day: 9}})
    assert 0 == (from e in StatusEmail, select: count(e.id)) |> Repo.one
    assert [] == DummyMailer.emails_sent
  end


  test "getting status emails", %{project: project1, pid: pid} do
    project2 = create_project("bob")
    project2 |> create_status_email
    project2 |> create_status_email

    status_email = project1 |> create_status_email

    assert [status_email] == pid |> ProjectEmails.project_status_emails
  end

  test "getting a single status email for a project", %{project: project, pid: pid} do
    status_email = project |> create_status_email
    assert {:ok, status_email} == pid |> ProjectEmails.project_status_email(status_email.id)
  end

  test "Can't get a status email for the wrong project", %{pid: pid} do
    project2 = create_project("2")
    wrong_email = project2 |> create_status_email

    assert {:error, :not_found} == pid |> ProjectEmails.project_status_email(wrong_email.id)
  end

  defp create_status_email(%Project{id: project_id})do
    %ProjectStatus.StatusEmail{project_id: project_id} |> Repo.insert!
  end

  defp create_project(name \\ "A project") do
    %Project{name: name}
    |> Repo.insert!
    |> add_recipients_to_project([{"Mavis", "mavis@example.com"}, {"Sue", "sue@example.com"}])
  end

  defp add_recipients_to_project(project, []), do: project
  defp add_recipients_to_project(project, [{name, email} | other_recipients]) do
    %EmailRecipient{project_id: project.id, name: name, email: email} |> Repo.insert!
    add_recipients_to_project(project, other_recipients)
  end
end
