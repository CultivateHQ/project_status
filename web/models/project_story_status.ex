defmodule ProjectStatus.ProjectStoryStatus do
  use ProjectStatus.Web, :model

  schema "project_story_statuses" do
    field :status_identifier, :string
    field :status_category, :string
    belongs_to :project, ProjectStatus.Project

    timestamps
  end

  @required_fields ~w(status_identifier status_category)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
