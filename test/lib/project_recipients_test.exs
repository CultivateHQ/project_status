defmodule ProjectRecipientsTest do
  use ProjectStatus.ModelCase
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient
  alias ProjectStatus.ProjectRecipients

  setup do
    project = create_project
    {:ok, pid} = ProjectRecipients.start(project.id)

    {:ok, %{project: project, pid: pid}}
  end

  test "successfully adding recipients to a project", %{project: project, pid: pid} do
    {:ok, recipient} = pid
    |> ProjectRecipients.add_recipient_to_project(%{"name" => "bob", "email" => "bob@bob.com"})

    [loaded_recipient] = (project |> Repo.preload(:email_recipients)).email_recipients
    assert loaded_recipient == recipient
  end

  test "failing to add recipients to a project", %{pid: pid} do
    assert {:error, changeset} = pid |>ProjectRecipients.add_recipient_to_project(%{})

    refute changeset.valid?
  end

  test "deleting a recipient", %{pid: pid} do
    recipient = Repo.insert! %EmailRecipient{}
    :ok = pid |> ProjectRecipients.delete_recipient(recipient.id)
    assert Repo.all(EmailRecipient) |> length == 0
  end

  test "retrieving recipients", %{pid: pid, project: project} do
    other_project = create_project("other")
    create_project_recipient(other_project)
    recipients = [create_project_recipient(project), create_project_recipient(project)]
    assert {:ok, recipients} == pid |> ProjectRecipients.project_recipients
  end

  defp create_project(name \\ "A project") do
    Repo.insert! %Project{name: name}
  end


  defp create_project_recipient(project) do
    %EmailRecipient{project_id: project.id} |> Repo.insert!
  end
end
