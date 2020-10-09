defmodule Prequest.Manage.ArticleCRUD do
  @moduledoc false

  alias Prequest.Manage.{Article, CRUD, Topic}
  alias Prequest.Repo

  use CRUD, schema: Article

  def create(attrs) do
    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topics, build_topics(attrs))
    |> Repo.insert()
  end

  def update(%Article{} = article, %{topics: _} = attrs) do
    article
    |> Repo.preload(:topics)
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topics, build_topics(attrs))
    |> Repo.update()
  end

  def update(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  # When create/1 or update/2 has :topics, it retrieve all existing topics
  defp build_topics(%{topics: topics} = _attrs),
    do: Enum.map(topics, &build_topic/1) |> Enum.uniq()

  defp build_topics(_), do: []

  # The :topics field can only accept a list containing %{name: name} and %Topic{}
  defp build_topic(%Topic{} = topic), do: topic

  defp build_topic(%{name: name}) do
    case Repo.get_by(Topic, name: name) do
      %Topic{} = topic -> topic
      nil -> Topic.changeset(%Topic{}, %{name: name})
    end
  end
end
