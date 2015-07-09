defmodule ProjectStatus.EmailRecipientTest do
  use ProjectStatus.ModelCase

  alias ProjectStatus.EmailRecipient

  @valid_attrs %{email: "bob@bob.com", name: "name", project_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "email validation" do
    changeset = EmailRecipient.changeset(%EmailRecipient{}, %{@valid_attrs | email: "blah"})
    refute changeset.valid?
  end
end
