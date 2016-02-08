defmodule ProjectStatus.TrackerSnapshotStoryStatus do
  use ProjectStatus.Web, :model

  schema "tracker_snapshot_story_status" do
    field :tracker_status_identifer, :string
    field :name, :string

    belongs_to :tracker_snapshot, ProjectStatus.TrackerSnapshot
    has_many :tracker_story_snapshots, ProjectStatus.TrackerStorySnapshot

    timestamps
  end

  @required_fields ~w(tracker_snapshot_id tracker_status_identifer name)
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
