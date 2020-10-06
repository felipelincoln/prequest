defmodule Prequest.Blog.FeedLoad do
  @moduledoc false

  import Ecto.Query
  alias Prequest.Blog.Feed
  alias Prequest.Repo

  @behaviour Feed

  @topics_quantity 20
  @per_page 2
  @sort_by [{:desc, :date}]

  def query(%{id: id} = source) when is_struct(source) do
    schema = source.__struct__

    %Feed{
      query: from(s in schema, where: s.id == ^id, join: a in assoc(s, :articles), as: :articles)
    }
  end

  def filter(%Feed{query: query}, :topics, values) when is_list(values) do
    %Feed{
      query:
        from([articles: a] in query,
          join: t in assoc(a, :topics),
          where: t.name in ^values
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
            group_by: t.id,
            select: {count(a.id), t},
            order_by: [desc: count(a.id)],
            limit: ^@topics_quantity
        )
    }
  end

  def view(%Feed{query: query, __meta__: %{articles_count: count}} = feed, opts \\ []) do
    page = Keyword.get(opts, :page, 0)
    per_page = Keyword.get(opts, :per_page, @per_page)
    sort_by = Keyword.get(opts, :sort_by, @sort_by)
    has_next? = (page + 1) * per_page < count

    articles =
      from([articles: a] in query, limit: ^per_page, offset: ^(per_page * page), select: a)
      |> sort(sort_by)

    feed
    |> Map.put(:articles, entries(articles))
    |> Map.put(:query, articles)
    |> put_metadata(%{has_next?: has_next?})
    |> put_metadata(%{page: page})
    |> put_metadata(%{per_page: per_page})
  end

  defp sort(query, [{type, :date}]) do
    from [articles: a] in query, order_by: [{^type, a.inserted_at}]
  end

  defp sort(query, [{type, :views}]) do
    from [articles: a] in query,
      group_by: a.id,
      left_join: v in assoc(a, :views),
      order_by: [{^type, count(v.id)}, {^type, a.inserted_at}]
  end

  defp put_metadata(%Feed{__meta__: meta} = feed, data) when is_map(data) do
    %{feed | __meta__: Map.merge(meta, data)}
  end

  defp count_entries(%Ecto.Query{} = query), do: Repo.aggregate(query, :count, :id)
  defp entries(%Ecto.Query{} = query), do: Repo.all(query)
end
