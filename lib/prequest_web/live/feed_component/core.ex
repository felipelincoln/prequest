defmodule PrequestWeb.FeedComponent.Core do
  @moduledoc false

  import Prequest.Manage.Topic.Color, only: [color_class: 1]
  import Prequest.Helpers, only: [preload!: 2]
  alias Prequest.Feed

  def create_build(source, range, filter) do
    build =
      source
      |> Feed.source(range)
      |> Feed.build(filter)

    {build, get_topics(build), get_reports(build)}
  end

  def create_feed(build, query, page, sort_by) do
    feed =
      build
      |> Feed.search(query)
      |> Feed.page(page, sort_by)

    {feed.__meta__, get_articles(feed)}
  end

  def apply_filter(meta, new_filter) do
    current_filter = get_filter(meta)

    case new_filter in current_filter do
      true -> List.delete(current_filter, new_filter)
      false -> [new_filter | current_filter]
    end
  end

  def get_filter(meta) do
    meta
    |> Map.get(:filter, {:topics, []})
    |> elem(1)
  end

  def sort_key(true), do: [desc: :date]
  def sort_key(false), do: [desc: :views]

  def next_page(page_str), do: String.to_integer(page_str) + 1

  defp get_articles(feed) do
    feed.articles
  end

  # list of {width, topic name, color}
  defp get_topics(%{topics: [], __meta__: %{topics_count: 0}}), do: []

  defp get_topics(%{topics: topics, __meta__: %{topics_count: count}}) do
    (topics ++ others_topic(topics, count))
    |> Enum.map(fn {n, topic} ->
      {n / count * 100, topic.name, color_class(topic.name)}
    end)
  end

  # list of {message, article title, inserted_at}
  defp get_reports(%{reports: reports}) do
    reports
    |> preload!(:article)
    |> Enum.map(fn %{message: message, article: article, inserted_at: inserted_at} ->
      {message, article.title, inserted_at}
    end)
  end

  defp others_topic(topics, count, name \\ "others") do
    limited_count = Enum.reduce(topics, 0, fn {n, _}, acc -> n + acc end)
    [{count - limited_count, %{name: name}}]
  end
end
