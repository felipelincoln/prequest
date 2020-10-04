defmodule Prequest.Load.Feed do
  @moduledoc false

  defstruct articles: [], count: 0, topics: [], topics_count: 0, reports: []

  @paginate_by 2

  def get(source, opts \\ []) do
    paginate_by = Keyword.get(opts, :paginate_by) || @paginate_by
    page = Keyword.get(opts, :page) || 0
    filter_title = Keyword.get(opts, :filter_title)
    filter_topics = Keyword.get(opts, :filter_topics)
    sort_by = Keyword.get(opts, :sort_by)

    articles =
      source
      |> Map.get(:articles)
      |> filter_by_title(filter_title)
      |> filter_by_topics(filter_topics)
      |> sort(sort_by)

    count = Enum.count(articles)

    reports =
      articles
      |> Enum.map(fn x -> x.reports end)
      |> List.flatten()

    topics =
      articles
      |> Enum.map(fn x -> x.topics end)
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.sort_by(&elem(&1, 1), :desc)

    topics_count =
      topics
      |> Enum.map(fn {_topic, count} -> count end)
      |> Enum.sum()

    __MODULE__.__struct__(%{
      articles: articles |> Enum.chunk_every(paginate_by) |> Enum.at(page),
      count: count,
      reports: reports,
      topics: topics,
      topics_count: topics_count
    })
  end

  defp filter_by_title(articles, nil), do: articles

  defp filter_by_title(articles, query) do
    articles
    |> Enum.map(fn x -> {String.bag_distance(x.title, query), x} end)
    |> Enum.filter(fn {score, _article} -> score > 0 end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
    |> Enum.map(fn {_score, article} -> article end)
  end

  defp filter_by_topics(articles, nil), do: articles

  defp filter_by_topics(articles, topics) when is_list(topics) do
    Enum.filter(articles, fn x ->
      article_topics = Enum.map(x.topics, fn x -> x.name end)
      article_topics -- topics != article_topics
    end)
  end

  defp sort(articles, nil), do: articles
  defp sort(articles, :date_desc), do: sort(articles, :date, :desc)
  defp sort(articles, :date_asc), do: sort(articles, :date, :asc)
  defp sort(articles, :views_desc), do: sort(articles, :views, :desc)
  defp sort(articles, :views_asc), do: sort(articles, :views, :asc)

  defp sort(articles, :date, order) do
    articles
    |> Enum.sort_by(&Map.get(&1, :inserted_at), {order, Date})
  end

  defp sort(articles, :views, order) do
    articles
    |> Enum.map(fn x -> {Enum.count(x.views), x} end)
    |> Enum.sort_by(&elem(&1, 0), order)
    |> Enum.map(fn {_views, article} -> article end)
  end
end
