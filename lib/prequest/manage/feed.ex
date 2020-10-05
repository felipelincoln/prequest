defmodule Prequest.Manage.Feed do
  @moduledoc false

  defstruct __meta__: %{}, query: nil, articles: [], reports: [], topics: []

  import Ecto.Query
  alias Prequest.Repo
  alias Prequest.Manage.Article
  alias Prequest.Manage.Feed

  @topics_quantity 20
  @per_page 2

  def query do
    %Feed{query: from(Article, as: :articles)}
  end

  def query(%{id: id} = source) when is_struct(source) do
    schema = source.__struct__

    %Feed{
      query: from(s in schema, where: s.id == ^id, join: a in assoc(s, :articles), as: :articles)
    }
  end

  def query(%{id: _id} = source, topics: topics) when is_struct(source) and is_list(topics) do
    %Feed{
      query:
        from([articles: a] in query(source),
          join: t in assoc(a, :topics),
          where: t.name in ^topics
        )
    }
  end

  def build(%Feed{query: query}) do
    topics = from [articles: a] in query, join: t in assoc(a, :topics), as: :topics
    reports = from [articles: a] in query, join: r in assoc(a, :reports), select: r

    %Feed{
      __meta__: %{
        articles_count: count_entries(query),
        topics_count: count_entries(topics)
      },
      query: query,
      reports: entries(reports),
      topics:
        entries(
          from [articles: a, topics: t] in topics,
            group_by: t.name,
            select: {t.name, count(a.id)},
            order_by: [desc: count(a.id)],
            limit: ^@topics_quantity
        )
    }
  end

  def view(%Feed{query: query, __meta__: %{articles_count: count}} = feed, opts \\ []) do
    page = Keyword.get(opts, :page, 0)
    per_page = Keyword.get(opts, :per_page, @per_page)
    has_next? = (page + 1) * per_page < count

    articles =
      entries(
        from [articles: a] in query, limit: ^per_page, offset: ^(per_page * page), select: a
      )

    feed
    |> Map.put(:articles, articles)
    |> put_metadata(%{has_next?: has_next?})
    |> put_metadata(%{page: page})
    |> put_metadata(%{per_page: per_page})
  end

  defp put_metadata(%Feed{__meta__: meta} = feed, data) when is_map(data) do
    %{feed | __meta__: Map.merge(meta, data)}
  end

  defp count_entries(%Ecto.Query{} = query), do: Repo.aggregate(query, :count, :id)
  defp entries(%Ecto.Query{} = query), do: Repo.all(query)
end
