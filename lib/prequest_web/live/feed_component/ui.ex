defmodule PrequestWeb.FeedComponent.UI do
  @moduledoc false

  import Prequest.Feed.Load.DateHelpers, only: [get_months_ago: 1]
  import Prequest.Manage.Topic.Color, only: [color_class: 1]
  import Prequest.Helpers, only: [preload!: 2]

  def last_feed?(range) do
    date = get_date(range)
    NaiveDateTime.compare(last_valid_date(), date) == :gt
  end

  def get_feed_name(0), do: "Recent"
  def get_feed_name(1), do: "Last month"

  def get_feed_name(range) do
    date = get_date(range)

    month =
      case date.month do
        1 -> "January"
        2 -> "February"
        3 -> "March"
        4 -> "April"
        5 -> "May"
        6 -> "June"
        7 -> "July"
        8 -> "August"
        9 -> "September"
        10 -> "October"
        11 -> "November"
        12 -> "December"
      end

    "#{month}, #{date.year}"
  end

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

  defp get_date(range) do
    [date, _] = get_months_ago(range)

    date
  end

  defp last_valid_date do
    {:ok, date} = NaiveDateTime.new(2020, 5, 1, 0, 0, 0)

    date
  end
end
