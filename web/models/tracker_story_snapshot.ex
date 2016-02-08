defmodule ProjectStatus.TrackerStorySnapshot do
  use ProjectStatus.Web, :model

  schema "tracker_story_snapshots" do
    field :tracker_story_identifier, :string
    field :story_points, :integer
    field :story_text, :string

    belongs_to :tracker_snapshot_story_status, ProjectStatus.TrackerSnapshotStoryStatus

    timestamps
  end

  @required_fields ~w(tracker_snapshot_story_status_id tracker_story_identifier story_points story_text)
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
