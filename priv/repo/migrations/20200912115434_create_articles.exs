defmodule Prequest.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string, null: false
      add :cover, :string, null: false
      add :source, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:articles, [:source])
    create index(:articles, [:user_id])
    create index(:articles, [:title])
  end
end
