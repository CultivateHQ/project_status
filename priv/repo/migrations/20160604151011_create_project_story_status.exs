defmodule ProjectStatus.Repo.Migrations.CreateProjectStoryStatus do
  use Ecto.Migration

  def change do
    create table(:project_story_statuses) do
      add :status_identifier, :string
      add :status_category, :string
      add :project_id, references(:projects)

      timestamps
    end
    create index(:project_story_statuses, [:project_id])
    create index(:project_story_statuses, [:status_identifier])

  end
end
