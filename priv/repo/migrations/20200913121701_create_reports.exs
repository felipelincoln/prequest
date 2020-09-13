defmodule Prequest.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :message, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps()
    end

    create index(:reports, [:user_id])
    create index(:reports, [:article_id])
  end
end
