defmodule ProjectStatus.ProjectEmailingTest do
  use ProjectStatus.ModelCase
  alias ProjectStatus.ProjectEmailing
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient


  test "sucessfully adding recipients to a project" do
    project = create_project
    assert {:ok, recipient} = project
      |> ProjectEmailing.add_recipient_to_project(%{"name" => "bob", "email" => "bob@bob.com"})

    assert [recipient] == (project |> Repo.preload(:email_recipients)).email_recipients
    assert recipient |> Map.take([:name, :email]) == %{name: "bob", email: "bob@bob.com"}
  end

  test "failing to add recipients to a project" do
    project = create_project
    assert {:error, changeset} = project |> ProjectEmailing.add_recipient_to_project(%{})
    refute changeset.valid?
  end

  test "deleting a recipient" do
    recipient = Repo.insert! %EmailRecipient{}
    ProjectEmailing.delete_email_recipient recipient
    assert Repo.all(EmailRecipient) |> length == 0
  end

  test "project recipients" do
    {project1, project2} = {create_project, create_project}
    {:ok, recipient} = ProjectEmailing.add_recipient_to_project project1, %{"name" => "bob", "email" => "bob@bob.com"}

    assert project1 |> ProjectEmailing.project_recipients == [recipient]
    assert project2 |> ProjectEmailing.project_recipients == []
  end

  test "creating a valid status email" do
    project = create_project
    assert {:ok, status_email} = project |>
      ProjectEmailing.create_status_email(%{"status_date" => %{year: 2015, month: 3, day: 9}, "content" => "Stuff happened"})
    assert [status_email] = (project |> Repo.preload(:status_emails)).status_emails
    assert status_email.status_date |> Ecto.Date.to_erl == {2015, 3, 9}
    assert status_email.subject == "Status update - A project - 2015-03-09"
  end


  test "getting status emails" do
    {project1, project2} = {create_project, create_project}
    {:ok, status_email} = project1 |>
      ProjectEmailing.create_status_email %{"status_date" => %{year: 2015, month: 2, day: 11}, "content" => "Stuff"}
    assert [status_email] == project1 |> ProjectEmailing.project_status_emails
    assert [] = project2 |> ProjectEmailing.project_status_emails
  end

  defp create_project(name \\ "A project") do
    Repo.insert! %Project{name: name}
  end
end
