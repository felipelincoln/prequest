defmodule PrequestWeb.HomeLive do
  @moduledoc """
  Homepage
  """

  use PrequestWeb, :live_view
  alias Prequest.Feed
  alias Prequest.Manage.Article
  alias Prequest.Manage.Topic.Color
  import Prequest.Helpers, only: [preload!: 2]

  def mount(_params, _session, socket) do
    feed =
      Article
      |> Feed.build()
      |> Feed.page(0)

    {:ok, assign(socket, :feed, feed)}
  end

  def handle_event("toggle_filter", %{"topic" => new_filter}, socket) do
    current_filter = get_filter(socket.assigns.feed)

    filter =
      case new_filter in current_filter do
        true -> List.delete(current_filter, new_filter)
        false -> [new_filter | current_filter]
      end

    feed =
      Article
      |> Feed.build(filter)
      |> Feed.page(0)

    {:noreply, assign(socket, :feed, feed)}
  end

  defp get_filter(feed) do
    feed.__meta__
    |> Map.get(:filter, {:topics, []})
    |> elem(1)
  end

  # list of {article title, inserted_at}
  defp ui(:articles, feed) do
    feed.articles
  end

  # list of {width, topic name, color}
  defp ui(:topics, %Feed{topics: [], __meta__: %{topics_count: 0}}), do: []

  defp ui(:topics, %Feed{topics: topics, __meta__: %{topics_count: count}}) do
    (topics ++ others_topic(topics, count))
    |> Enum.map(fn {n, topic} ->
      {n / count * 100, topic.name, Color.from(topic.name)}
    end)
  end

  # list of {message, article title, inserted_at}
  defp ui(:reports, %Feed{reports: reports}) do
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
