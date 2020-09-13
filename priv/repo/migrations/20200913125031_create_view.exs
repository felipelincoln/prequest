defmodule Prequest.Repo.Migrations.CreateView do
  use Ecto.Migration

  def change do
    create table(:view) do
      add :liked?, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :article_id, references(:articles, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:view, [:user_id])
    create index(:view, [:article_id])
  end
end
