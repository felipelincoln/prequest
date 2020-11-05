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
    source = Article
    build = Feed.build(source)
    feed = build |> Feed.page(0)

    socket =
      socket
      |> assign(:source, source)
      |> assign(:build, build)
      |> assign(:feed, feed)
      |> assign(:update, "replace")

    {:ok, socket, temporary_assigns: [feed: nil]}
  end

  def handle_event("load", %{"page" => page}, socket) do
    feed =
      socket.assigns.build
      |> Feed.page(String.to_integer(page) + 1)

    socket =
      socket
      |> assign(:feed, feed)
      |> assign(:update, "append")

    {:noreply, socket}
  end

  def handle_event("toggle_filter", %{"topic" => new_filter}, socket) do
    current_filter = get_filter(socket.assigns.build)

    filter =
      case new_filter in current_filter do
        true -> List.delete(current_filter, new_filter)
        false -> [new_filter | current_filter]
      end

    build = Feed.build(socket.assigns.source, filter)
    feed = build |> Feed.page(0)

    socket =
      socket
      |> assign(:build, build)
      |> assign(:feed, feed)
      |> assign(:update, "replace")

    {:noreply, socket}
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

  defp get_filter(feed) do
    feed.__meta__
    |> Map.get(:filter, {:topics, []})
    |> elem(1)
  end
end
