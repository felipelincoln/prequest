defmodule Prequest.Feed.Load do
  @moduledoc false

  import Ecto.Query
  alias Prequest.Feed
  alias Prequest.Feed.Impl
  alias Prequest.Repo

  @behaviour Impl

  @topics_quantity 2
  @reports_quantity 2
  @per_page 2
  @sort_by [{:desc, :date}]

  def query(%{id: id} = source) when is_struct(source) do
    schema = source.__struct__

    %Feed{
      query: from(s in schema, where: s.id == ^id, join: a in assoc(s, :articles), as: :articles)
    }
  end

  def filter(%Feed{query: query} = feed, :topics, values) when is_list(values) do
    query_filter =
      from([articles: a] in query, join: t in assoc(a, :topics), where: t.name in ^values)

    feed
    |> put(:query, query_filter)
  end

  def build(%Feed{query: query} = feed) do
    topics = from [articles: a] in query, join: t in assoc(a, :topics), as: :topics

    topics_limited =
      from [articles: a, topics: t] in topics,
        group_by: t.id,
        select: {count(a.id), t},
        order_by: [desc: count(a.id)],
        limit: ^@topics_quantity

    reports =
      from [articles: a] in query,
        join: r in assoc(a, :reports),
        select: r,
        order_by: [desc: r.inserted_at],
        limit: ^@reports_quantity

    feed
    |> put(:reports, entries(reports))
    |> put(:topics, entries(topics_limited))
    |> put_metadata(:articles_count, count_entries(query))
    |> put_metadata(:topics_count, count_entries(topics))
  end

  def view(%Feed{query: query, __meta__: %{articles_count: count}} = feed, opts \\ []) do
    page = Keyword.get(opts, :page, 0)
    per_page = Keyword.get(opts, :per_page, @per_page)
    sort_by = Keyword.get(opts, :sort_by, @sort_by)
    has_next? = (page + 1) * per_page < count

    query_articles =
      from([articles: a] in query, limit: ^per_page, offset: ^(per_page * page), select: a)
      |> sort(sort_by)

    feed
    |> put(:query, query_articles)
    |> put_metadata(:has_next?, has_next?)
    |> put_metadata(:page, page)
    |> put_metadata(:per_page, per_page)
  end

  def load(%Feed{query: query} = feed), do: %{feed | articles: entries(query)}

  defp sort(query, [{type, :date}]) do
    from [articles: a] in query, order_by: [{^type, a.inserted_at}]
  end

  defp sort(query, [{type, :views}]) do
    from [articles: a] in query,
      group_by: a.id,
      left_join: v in assoc(a, :views),
      order_by: [{^type, count(v.id)}, {^type, a.inserted_at}]
  end

  defp put(%Feed{} = feed, key, value) when is_atom(key), do: Map.put(feed, key, value)

  defp put_metadata(%Feed{__meta__: meta} = feed, key, value) when is_atom(key) do
    data = Map.new([{key, value}])
    %{feed | __meta__: Map.merge(meta, data)}
  end

  defp count_entries(%Ecto.Query{} = query), do: Repo.aggregate(query, :count, :id)
  defp entries(%Ecto.Query{} = query), do: Repo.all(query)
end
