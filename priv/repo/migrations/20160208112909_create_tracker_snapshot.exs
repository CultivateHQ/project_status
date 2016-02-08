defmodule ProjectStatus.Repo.Migrations.CreateTrackerSnapshot do
  use Ecto.Migration

  def change do
    create table(:tracker_snapshots) do
      add :snapshot_datetime, :datetime
      add :project_id, :integer

      timestamps
    end

  end
end
