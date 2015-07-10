defmodule ProjectStatus.ProjectStatusEmailChannelTest do
  use ProjectStatus.ChannelCase

  alias ProjectStatus.ProjectStatusEmailChannel
  alias ProjectStatus.ProjectEmailing

  import Mock

  setup do
    {:ok, _, socket} = subscribe_and_join(ProjectStatusEmailChannel, "project_status_emails:123")
    socket_with_project_id = %{socket | assigns: %{project_id: "123"}} # test scaffolding doesn't reflect assigns
    {:ok, socket: socket_with_project_id}
  end

  test "new_status_email_created_with_project_id_and_correct_params", %{socket: socket} do
    with_mock ProjectEmailing, [create_status_email: fn(project_id, params) ->
                                 assert project_id == "123"
                                 assert params["content"] == "The email content"
                                 assert params["status_date"] == %{year: 2014, month: 11, day: 2}
                                 {:ok, %{}}
                               end ] do
      ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => "The email content"}
      assert_reply ref, :ok, %{status_email: %{}}
    end
  end

  test "new_status_email empty content is converted to nil", %{socket: socket} do
    with_mock ProjectEmailing, [create_status_email: fn(_project_id, params) ->
                                 assert params["content"] == nil
                                 {:ok, %{}}
                               end ] do
      ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => ""}
      assert_reply ref, :ok, %{status_email: %{}}
    end
  end

  test "new_status_email replies with :error with changeset on failure", %{socket: socket} do
    changeset = {:dummy_changeset}
    with_mock ProjectEmailing, [create_status_email: fn(_,_) -> {:error, changeset} end ] do
      ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => "content"}
      assert_reply ref, :error, %{changeset: changeset}
    end
  end

  test "new_status_email replies with :ok and model on failure", %{socket: socket} do
    model = %{fake_model: :fake}
    with_mock ProjectEmailing, [create_status_email: fn(_,_) -> {:ok, model} end ] do
      ref = push socket, "send_status_email", %{"status_date" => "2014-11-2", "content" => "content"}
      assert_reply ref, :ok, %{status_email: model}
      assert_broadcast "new_status_email", model
    end
  end

  test "get_project_status_emails", %{socket: socket} do
    emails = [:fake_status_emails]
    with_mock ProjectEmailing, [project_status_emails: fn(project_id) ->
                                 assert project_id == "123"
                                 emails
                               end ] do
      ref = push socket, "get_project_status_emails"
      assert_reply ref, :ok, %{status_emails: emails}
    end
  end

end
