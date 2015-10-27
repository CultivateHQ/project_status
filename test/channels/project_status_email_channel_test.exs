defmodule ProjectStatus.ProjectStatusEmailChannelTest do
  use ProjectStatus.ChannelCase

  alias ProjectStatus.ProjectStatusEmailChannel

  alias ProjectStatus.Project
  alias ProjectStatus.StatusEmail
  alias ProjectStatus.Repo

  setup do
    DummyMailer.start_link

    %{id: project_id} = %Project{name: "test project"} |> Repo.insert!

    sock = socket()
    |> subscribe_and_join!(ProjectStatusEmailChannel, "project_status_emails:#{project_id}")

    {:ok, socket: sock, project_id: project_id}
  end

  test "new_status_email_created_with_project_id_and_correct_params", %{socket: socket, project_id: project_id} do
    ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => "The email content"}
    assert_reply ref, :ok, %{status_email: created_email}
    assert created_email.project_id == project_id
    assert created_email.content == "The email content"
    assert created_email.status_date |> Ecto.Date.to_erl == {2014, 11, 2}
  end

  test "new_status_email empty content is converted to nil", %{socket: socket} do
    ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => ""}
    assert_reply ref, :error, %{changeset: %Ecto.Changeset{valid?: false}}
  end

  test "new_status_email replies with :error if failed to send", %{socket: socket} do
    DummyMailer.set_emailing_result(:error)
    ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => "content"}
    assert_reply ref, :email_failed
  end

  test "new_status_email replies with :ok and model on sucess", %{socket: socket} do
    ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => "content"}
    assert_reply ref, :ok, %{status_email: %{content: "content"}}
    assert_broadcast "new_status_email", %{content: "content"}
  end

  test "get_project_status_emails", %{socket: socket, project_id: project_id} do
    emails = [create_status_email(project_id, "email 1"), create_status_email(project_id, "email 2")]
    ref = push socket, "get_project_status_emails"
    assert_reply ref, :ok, %{status_emails: ^emails}
  end

  defp create_status_email(project_id, content) do
    %StatusEmail{content: content, project_id: project_id} |> Repo.insert!
  end

  test "preview_content", %{socket: socket} do
    ref = push socket, "preview_content", %{"markdown" => "# Hello"}
    assert_reply ref, :ok, %{html: "<h1>Hello</h1>\n"}
  end


end
