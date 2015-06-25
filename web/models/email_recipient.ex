defmodule ProjectStatus.EmailRecipient do
  use ProjectStatus.Web, :model

  schema "email_recipients" do
    field :name, :string
    field :email, :string

    belongs_to :project, ProjectStatus.Project
    timestamps
  end

  @required_fields ~w(project_id name email)
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
end
