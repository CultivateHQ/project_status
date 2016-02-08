defmodule ProjectStatus.Repo.Migrations.CreateTrackerStorySnapshot do
  use Ecto.Migration

  def change do
    create table(:tracker_story_snapshots) do
      add :tracker_snapshot_story_status_id, :integer
      add :tracker_story_identifier, :string
      add :story_points, :integer
      add :story_text, :text

      timestamps
    end

  end
end
