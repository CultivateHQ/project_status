defmodule ProjectStatus.ProjectEmailRecipientChannelTest do
  use ProjectStatus.ChannelCase

  alias ProjectStatus.ProjectEmailRecipientChannel
  alias ProjectStatus.ProjectEmailing
  alias ProjectStatus.EmailRecipient

  import Mock

  setup do
    {:ok, _, socket} = subscribe_and_join(ProjectEmailRecipientChannel, "project_email_recipients:123")
    socket_with_project_id = %{socket | assigns: %{project_id: "123"}} # test scaffolding doesn't reflect assigns
    {:ok, socket: socket_with_project_id}
  end


  test "new_project_email_recipient returns :ok, with the new recipient, on success", %{socket: socket} do
    recipient = %EmailRecipient{name: "bob"}
    with_mock ProjectEmailing,
    [add_recipient_to_project: fn(_, _) -> {:ok, recipient} end] do

      ref = push socket, "new_project_email_recipient", %{"email" => "", "name" => ""}
      assert_reply ref, :ok, %{email_recipient: recipient}
    end
  end

  test "new_project_email_recipient broadcasts the new reciient", %{socket: socket} do
    recipient = %EmailRecipient{name: "bob"}
    with_mock ProjectEmailing,
    [add_recipient_to_project: fn(_, _) -> {:ok, recipient} end] do

      ref = push socket, "new_project_email_recipient", %{"email" => "", "name" => ""}
      assert_broadcast "new_project_email_recipient", %{email_recipient: recipient}
    end
  end

  test "new_project_email_recipient returns :error with changest on failure", %{socket: socket} do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, %{name: "bob"})
    with_mock ProjectEmailing, [add_recipient_to_project: fn(_,_) -> {:error, changeset} end] do
      ref = push socket, "new_project_email_recipient", %{"email" => "", "name" => ""}
      assert_reply ref, :error, %{changeset: changeset}
    end
  end

  test "new_project_email_recipient calls ProjectEmailing.add_recipient_to_project with project id and params",
    %{socket: socket} do
    with_mock ProjectEmailing, [add_recipient_to_project: fn(project_id, params) ->
                                 assert project_id == "123"
                                 assert params == %{"name" => "bob", "email" => "bob@bob.com"}
                                 {:ok, %{}}
                               end] do
      ref = push socket, "new_project_email_recipient", %{"name" => "bob", "email" => "bob@bob.com"}
      assert_reply ref, :ok, %{email_recipient: %{}} #without assert message is not pushed
    end
  end

  test "new_project_email_recipient params are scrubbed", %{socket: socket} do
    with_mock ProjectEmailing, [add_recipient_to_project: fn(_, params) ->
                                   assert params == %{"name" => nil, "email" => nil}
                                   {:ok, %{}}
                                 end] do
      ref = push socket, "new_project_email_recipient", %{"name" => "", "email" => ""}
      assert_reply ref, :ok, %{email_recipient: %{}} #without assert message is not pushed
    end
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end



  test "shout broadcasts to project_email_recipients:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
