defmodule ProjectStatus.ProjectTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.Project

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create email_recipient changeset with project" do
   project = %Project{name: "My Project", id: 67}
   email_recipient = project |> Project.new_email_recipient(%{"name" => "Petra", "email" => "petra@bluepeter.co.uk"})
   assert email_recipient.changes.name == "Petra"
   assert email_recipient.changes.email == "petra@bluepeter.co.uk"
   assert email_recipient.changes.project_id == project.id
   assert email_recipient.valid?
  end

  test "create email_recipient_changeset with project id" do
    project = %Project{name: "My Project", id: 67}
    email_recipient = 67 |> Project.new_email_recipient(%{"name" => "Petra", "email" => "petra@bluepeter.co.uk"})
    assert email_recipient.changes.name == "Petra"
    assert email_recipient.changes.email == "petra@bluepeter.co.uk"
    assert email_recipient.changes.project_id == project.id
    assert email_recipient.valid?
  end
end
