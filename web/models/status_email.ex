defmodule ProjectStatus.StatusEmail do
  use ProjectStatus.Web, :model

  schema "status_emails" do
    field :status_date, Ecto.Date
    field :sent_date, Ecto.Date
    field :subject, :string
    field :content, :string

    belongs_to :project, ProjectStatus.Project
    timestamps
  end

  @required_fields ~w(status_date subject content project_id)
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
