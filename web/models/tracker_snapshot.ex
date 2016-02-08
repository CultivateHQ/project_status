defmodule ProjectStatus.TrackerSnapshot do
  use ProjectStatus.Web, :model

  schema "tracker_snapshots" do
    field :snapshot_datetime, Ecto.DateTime
    belongs_to :project, ProjectStatus.Project
    has_many :tracker_snapshot_story_status, ProjectStatus.TrackerSnapshotStoryStatus

    timestamps
  end

  @required_fields ~w(snapshot_datetime project_id)
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
