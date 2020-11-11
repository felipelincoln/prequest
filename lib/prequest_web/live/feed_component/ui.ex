defmodule PrequestWeb.FeedComponent.UI do
  @moduledoc false

  import Prequest.Manage.Topic.Color, only: [color_class: 1]
  import Prequest.Helpers, only: [preload!: 2]

  def get_articles(feed) do
    feed.articles
  end

  # list of {width, topic name, color}
  def get_topics(%{topics: [], __meta__: %{topics_count: 0}}), do: []

  def get_topics(%{topics: topics, __meta__: %{topics_count: count}}) do
    (topics ++ others_topic(topics, count))
    |> Enum.map(fn {n, topic} ->
      {n / count * 100, topic.name, color_class(topic.name)}
    end)
  end

  # list of {message, article title, inserted_at}
  def get_reports(%{reports: reports}) do
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
