defmodule ProjectStatus.Project do
  use ProjectStatus.Web, :model
  alias ProjectStatus.EmailRecipient

  schema "projects" do
    field :name, :string

    has_many :email_recipients, EmailRecipient
    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def new_email_recipient(%ProjectStatus.Project{id: project_id}, email_recipient_params ) do
    new_email_recipient(project_id, email_recipient_params)
  end

  def new_email_recipient(project_id, email_recipient_params) do
    EmailRecipient.changeset(%EmailRecipient{}, email_recipient_params |> Map.put("project_id", project_id))
  end
end
