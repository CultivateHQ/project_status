defmodule ProjectStatus.ProjectEmailRecipientChannelTest do
  use ProjectStatus.ChannelCase

  alias ProjectStatus.ProjectEmailRecipientChannel
  alias ProjectStatus.ProjectEmailing
  alias ProjectStatus.EmailRecipient

  import Mock

  setup do
    sock = socket()
    |> subscribe_and_join!(ProjectEmailRecipientChannel, "project_email_recipients:123")
    |> Map.put(:assigns, %{project_id: "123"})
    {:ok, socket: sock}
  end


  test "new_project_email_recipient returns :ok, with the new recipient, on success", %{socket: socket} do
    recipient = %EmailRecipient{name: "bob"}
    with_mock ProjectEmailing,
    [add_recipient_to_project: fn(_, _) -> {:ok, recipient} end] do

      ref = push socket, "new_project_email_recipient", %{"email" => "", "name" => ""}
      assert_reply ref, :ok, %{email_recipient: recipient}
    end
  end

  test "new_project_email_recipient broadcasts the new recipient", %{socket: socket} do
    recipient = %EmailRecipient{name: "bob"}
    with_mock ProjectEmailing,
    [add_recipient_to_project: fn(_, _) -> {:ok, recipient} end] do

      push socket, "new_project_email_recipient", %{"email" => "", "name" => ""}
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
                                 {:ok, %EmailRecipient{}}
                               end] do
      ref = push socket, "new_project_email_recipient", %{"name" => "bob", "email" => "bob@bob.com"}
      assert_reply ref, :ok, %{email_recipient: %{}} #without assert message is not pushed
    end
  end

  test "new_project_email_recipient params are scrubbed", %{socket: socket} do
    with_mock ProjectEmailing, [add_recipient_to_project: fn(_, params) ->
                                   assert params == %{"name" => nil, "email" => nil}
                                   {:ok, %EmailRecipient{}}
                                 end] do
      ref = push socket, "new_project_email_recipient", %{"name" => "", "email" => ""}
      assert_reply ref, :ok, %{email_recipient: %{}} #without assert message is not pushed
    end
  end

  test "recipient deleted", %{socket: socket} do
    with_mock ProjectEmailing, [delete_email_recipient: fn(id) ->
                                 assert id == "456"
                                 :ok
                               end] do
      ref = push socket, "delete_project_email_recipient", %{"id" => "456"}
      assert_reply ref, :ok, %{id: "456"}
    end
  end

  test "deleted recipient broadcast", %{socket: socket} do
    with_mock ProjectEmailing, [delete_email_recipient: fn(_) -> :ok end] do
      push socket, "delete_project_email_recipient", %{"id" => "790"}
      assert_broadcast  "delete_project_email_recipient", %{id: "790"}
    end
  end

  test "project recipients", %{socket: socket} do
    recipients = [%EmailRecipient{name: "bob"}, %EmailRecipient{name: "mavis"}]
    with_mock ProjectEmailing, [project_recipients: fn(project_id) ->
                               assert project_id == "123"
                               recipients
                               end] do
      ref = push socket, "project_email_recipients"
      assert_reply ref, :ok, %{project_email_recipients: recipients}
    end
  end
end
