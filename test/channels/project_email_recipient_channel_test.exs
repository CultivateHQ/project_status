defmodule ProjectStatus.ProjectEmailRecipientChannelTest do
  use ProjectStatus.ChannelCase

  alias ProjectStatus.ProjectEmailRecipientChannel
  alias ProjectStatus.Project
  alias ProjectStatus.EmailRecipient
  alias ProjectStatus.Repo

  @valid_attrs %{"email" => "bob@bob.com", "name" => "name"}
  @invalid_attrs %{}

  setup do
    %{id: project_id} = %Project{name: "A project"} |> Repo.insert!
    sock = socket()
    |> subscribe_and_join!(ProjectEmailRecipientChannel, "project_email_recipients:#{project_id}")
    {:ok, socket: sock, project_id: project_id}
  end


  test "new_project_email_recipient returns :ok, with the new recipient, on success", %{socket: socket, project_id: project_id} do
    ref = push socket, "new_project_email_recipient", @valid_attrs
    assert_reply ref, :ok, %{email_recipient: %{email: "bob@bob.com", project_id: project_id}}
  end

  test "new_project_email_recipient broadcasts the new recipient", %{socket: socket} do
    ref = push socket, "new_project_email_recipient", @valid_attrs
    assert_broadcast "new_project_email_recipient", %{email_recipient: %{email: "bob@bob.com"}}
  end

  test "new_project_email_recipient returns :error with changest on failure", %{socket: socket} do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, @invalid_attrs)
    ref = push socket, "new_project_email_recipient", %{"email" => "", "name" => ""}
    assert_reply ref, :error, %{changeset: changeset}
  end

  test "new_project_email_recipient params are scrubbed", %{socket: socket} do
    ref = push socket, "new_project_email_recipient", %{"name" => "", "email" => ""}
    assert_reply ref, :error, %{}
  end

  test "recipient deleted", %{socket: socket, project_id: project_id} do
    delete_id = insert_recipient(project_id, "Mavis")
    ref = push socket, "delete_project_email_recipient", %{"id" => delete_id}
    assert_reply ref, :ok, %{id: delete_id}
  end

  test "deleted recipient broadcast", %{socket: socket, project_id: project_id} do
    delete_id = insert_recipient(project_id, "Mavis")
    push socket, "delete_project_email_recipient", %{"id" => delete_id}
    assert_broadcast  "delete_project_email_recipient", %{id: delete_id}
  end

  test "project recipients", %{socket: socket, project_id: project_id} do
    recipients = [insert_recipient(project_id, "Bob"), insert_recipient(project_id, "Mavis")]
    ref = push socket, "project_email_recipients"
    assert_reply ref, :ok, %{project_email_recipients: recipients}
  end

  defp insert_recipient(project_id, name) do
    %{id: id} = %EmailRecipient{project_id: 123, name: name} |> Map.merge(@valid_attrs) |> Repo.insert!
    id
  end
end
