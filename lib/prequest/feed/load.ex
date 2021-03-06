defmodule Prequest.Feed.Load do
  @moduledoc false

  import Ecto.Query
  import Prequest.Helpers, only: [preload!: 2]
  import Prequest.Feed.Load.DateHelpers, only: [get_months_ago: 1]
  alias Prequest.Feed
  alias Prequest.Feed.Impl
  alias Prequest.Repo

  @behaviour Impl

  @topics_quantity 11
  @reports_quantity 10
  @per_page 10
  @sort_by [{:desc, :date}]

  def source(article_schema, n) when is_atom(article_schema) and is_integer(n) do
    [date_a | [date_b]] = get_months_ago(n)

    from(a in article_schema,
      as: :articles,
      where: a.updated_at >= ^date_a and a.updated_at < ^date_b,
      select: a
    )
  end

  def source(%{id: id} = source, n) when is_struct(source) and is_integer(n) do
    schema = source.__struct__
    [date_a | [date_b]] = get_months_ago(n)

    from(s in schema,
      where: s.id == ^id,
      join: a in assoc(s, :articles),
      as: :articles,
      where: a.updated_at >= ^date_a and a.updated_at < ^date_b,
      select: a
    )
  end

  def query(%Ecto.Query{} = ecto_query) do
    %Feed{query: ecto_query}
  end

  def query(article_schema) when is_atom(article_schema) do
    %Feed{query: from(a in article_schema, as: :articles, select: a)}
  end

  def query(%{id: id} = source) when is_struct(source) do
    schema = source.__struct__

    %Feed{
      query:
        from(s in schema,
          where: s.id == ^id,
          join: a in assoc(s, :articles),
          as: :articles,
          select: a
        )
    }
  end

  def filter(%Feed{query: _query} = feed, :topics, []), do: feed

  def filter(%Feed{query: query} = feed, :topics, values) when is_list(values) do
    query_filter =
      from [articles: a] in query,
        join: t in assoc(a, :topics),
        where: t.name in ^values,
        group_by: a.id,
        having: count(t.id, :distinct) == ^Enum.count(values)

    feed
    |> put(:query, query_filter)
    |> put_metadata(:filter, {:topics, values})
  end

  def build(%Feed{query: query} = feed) do
    topics =
      from a in subquery(query),
        as: :articles,
        join: t in assoc(a, :topics),
        as: :topics

    topics_limited =
      from [articles: a, topics: t] in topics,
        group_by: t.id,
        order_by: [desc: count(a.id)],
        limit: ^@topics_quantity,
        select: {count(a.id), t}

    reports_limited =
      from a in subquery(query),
        join: r in assoc(a, :reports),
        order_by: [desc: r.updated_at],
        limit: ^@reports_quantity,
        select: r

    results = count_entries(query)

    feed
    |> put(:reports, entries(reports_limited))
    |> put(:topics, entries(topics_limited))
    |> put_metadata(:topics_count, count_entries(topics))
    |> put_metadata(:articles_count, results)
    |> put_metadata(:results, results)
  end

  def search(%Feed{query: _query} = feed, ""), do: feed

  def search(%Feed{query: query} = feed, substring) when is_binary(substring) do
    substring = String.replace(substring, ~r/([%_])/, ~S"\\" <> "\\g{1}")

    query_search =
      from [articles: a] in query,
        where: ilike(a.title, ^"%#{substring}%") or ilike(a.subtitle, ^"%#{substring}%")

    feed
    |> put(:query, query_search)
    |> put_metadata(:results, count_entries(query_search))
    |> put_metadata(:search, substring)
  end

  def view(%Feed{query: query, __meta__: %{results: results}} = feed, opts \\ []) do
    page = Keyword.get(opts, :page, 0)
    per_page = Keyword.get(opts, :per_page, @per_page)
    sort_by = Keyword.get(opts, :sort_by, @sort_by)
    has_next? = (page + 1) * per_page < results

    query_articles =
      from([articles: a] in query, limit: ^per_page, offset: ^(per_page * page))
      |> sort(sort_by)

    feed
    |> put(:query, query_articles)
    |> put_metadata(:has_next?, has_next?)
    |> put_metadata(:page, page)
    |> put_metadata(:per_page, per_page)
    |> put_metadata(:sort_by, sort_by)
  end

  def load(%Feed{query: query} = feed), do: %{feed | articles: entries(query) |> preload!(:user)}

  defp sort(query, [{type, :date}]) do
    from [articles: a] in query, order_by: [{^type, a.updated_at}]
  end

  defp sort(query, [{type, :views}]) do
    from [articles: a] in query,
      group_by: a.id,
      left_join: v in assoc(a, :views),
      order_by: [{^type, count(v.id)}, {^type, a.updated_at}]
  end

  defp put(%Feed{} = feed, key, value) when is_atom(key), do: Map.put(feed, key, value)

  defp put_metadata(%Feed{__meta__: meta} = feed, key, value) when is_atom(key) do
    data = Map.new([{key, value}])
    %{feed | __meta__: Map.merge(meta, data)}
  end

  #  defp get_metadata(%Feed{__meta__: meta}, key, default) when is_atom(key),
  #  do: Map.get(meta, key, default)

  defp count_entries(%Ecto.Query{} = query),
    do: Repo.one(from x in subquery(query), select: count(x.id))

  defp entries(%Ecto.Query{} = query), do: Repo.all(query)
end
