defmodule Prequest.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :cover, :string
      add :source, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:articles, [:source])
    create index(:articles, [:user_id])
    create index(:articles, [:title])
  end
end
