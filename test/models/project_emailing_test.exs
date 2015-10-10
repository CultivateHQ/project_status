defmodule ProjectStatus.ProjectEmailingTest do
  use ProjectStatus.ModelCase
  alias ProjectStatus.ProjectEmailing
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient
  alias ProjectStatus.Mailing.Mailer
  alias ProjectStatus.StatusEmail

  import Mock
  import Ecto.Query


  test "successfully adding recipients to a project" do
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
    project = create_project_with_recipients([{"bob", "bob@example.com"}, {"sue", "sue@example.com"}])
    with_mock Mailer, [send: fn(_,_,_ ) -> {:ok, {}} end] do
      assert {:ok, status_email} = project |>
        ProjectEmailing.create_status_email(%{"status_date" => %{year: 2015, month: 3, day: 9}, "content" => "Stuff happened"})
      assert [status_email] = (project |> Repo.preload(:status_emails)).status_emails
      assert status_email.status_date |> Ecto.Date.to_erl == {2015, 3, 9}
      assert status_email.subject == "Status update - A project - 2015-03-09"
      assert status_email.content == "Stuff happened"
      assert called Mailer.send "bob <bob@example.com>,sue <sue@example.com>", status_email.subject, status_email.content
    end
  end

  test "email failed to send" do
    project = create_project_with_recipients {"bob", "bob@exmple.com"}
    with_mock Mailer, [send: fn(_,_,_) -> :error end] do
      {:error, :email_failed} = project |>
        ProjectEmailing.create_status_email(%{"status_date" => %{year: 2015, month: 3, day: 9}, "content" => "Stuff happened"})
      assert 0 == (from e in StatusEmail, select: count(e.id)) |> Repo.one
    end
  end

  test "email fails validation" do
    project = create_project_with_recipients {"bob", "bob@exmple.com"}
    with_mock Mailer, [send: fn(_,_,_) -> flunk "Email should not send" end] do
      {:error, changeset} = project |> ProjectEmailing.create_status_email(%{"status_date" => %{year: 2015, month: 1, day: 9}})
      assert 0 == (from e in StatusEmail, select: count(e.id)) |> Repo.one
      assert %Ecto.Changeset{valid?: false} = changeset
    end
  end


  test "getting status emails" do
    {project1, project2} = {create_project, create_project}
    status_email = project1 |> create_status_email
    assert [status_email] == project1 |> ProjectEmailing.project_status_emails
    assert [] = project2 |> ProjectEmailing.project_status_emails
  end

  test "getting a single status email for a project" do
    project = create_project
    status_email = project |> create_status_email
    assert {:ok, status_email} == ProjectEmailing.project_status_email(project, status_email.id)
  end

  test "Can't get a status email for the wrong project" do
    {project1, project2} = {create_project, create_project}
    status_email = project1 |> create_status_email

    assert :not_found == ProjectEmailing.project_status_email(project2, status_email.id)
  end

  defp create_project(name \\ "A project") do
    Repo.insert! %Project{name: name}
  end


  defp create_project_with_recipients recipients = {_,_} do
    create_project_with_recipients [recipients]
  end

  defp create_project_with_recipients recipients do
    recipients |> Enum.reduce(create_project, fn({name, email}, project) ->
      project |> ProjectEmailing.add_recipient_to_project(%{"name" => name, "email" => email})
      project
    end)
  end

  defp create_status_email(%Project{id: project_id})do
    %ProjectStatus.StatusEmail{project_id: project_id} |> Repo.insert!
  end
end
