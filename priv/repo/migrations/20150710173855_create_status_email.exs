defmodule ProjectStatus.Repo.Migrations.CreateStatusEmail do
  use Ecto.Migration

  def change do
    create table(:status_emails) do
      add :status_date, :date
      add :sent_date, :date
      add :subject, :string
      add :content, :text
      add :project_id, :integer

      timestamps
    end

  end
end
