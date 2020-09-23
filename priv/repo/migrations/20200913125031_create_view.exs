defmodule Prequest.Repo.Migrations.CreateView do
  use Ecto.Migration

  def change do
    create table(:views) do
      add :liked?, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :article_id, references(:articles, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:views, [:user_id])
    create index(:views, [:article_id])
    create unique_index(:views, [:user_id, :article_id], name: :user_article_view_constraint)
  end
end
