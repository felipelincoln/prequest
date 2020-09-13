defmodule Prequest.Repo.Migrations.CreateArticlesTopics do
  use Ecto.Migration

  def change do
    create table(:articles_topics) do
      add :article_id, references(:articles, on_delete: :delete_all)
      add :topic_id, references(:topics, on_delete: :delete_all)
    end

    create index(:articles_topics, :article_id)
    create index(:articles_topics, :topic_id)
  end
end
