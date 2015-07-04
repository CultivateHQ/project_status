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


  defp create_project do
    Repo.insert! %Project{}
  end

end
