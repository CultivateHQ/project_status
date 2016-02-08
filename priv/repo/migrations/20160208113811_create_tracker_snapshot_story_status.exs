defmodule ProjectStatus.Repo.Migrations.CreateTrackerSnapshotStoryStatus do
  use Ecto.Migration

  def change do
    create table(:tracker_snapshot_story_status) do
      add :tracker_snapshot_id, :integer
      add :tracker_status_identifer, :string
      add :name, :string

      timestamps
    end

  end
end
