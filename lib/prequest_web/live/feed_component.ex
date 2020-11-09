defmodule PrequestWeb.FeedComponent do
  @moduledoc """
  The component for feed
  """

  use Phoenix.LiveComponent
  alias Prequest.Feed
  alias PrequestWeb.FeedComponent.UI

  @impl true
  def mount(socket) do
    IO.puts("component mounted")
    {:ok, socket, temporary_assigns: [articles: nil]}
  end

  @impl true
  def update(%{id: id, source: source, range: range}, socket) do
    IO.puts("component #{range} updated")

    build =
      source
      |> Feed.source(range)
      |> Feed.build()

    topics = build |> UI.get_topics()
    reports = build |> UI.get_reports()
    feed = build |> Feed.page(0)
    articles = feed |> UI.get_articles()
    meta = feed.__meta__

    socket =
      socket
      |> assign(:id, id)
      |> assign(:source, source)
      |> assign(:range, range)
      |> assign(:build, build)
      |> assign(:topics, topics)
      |> assign(:reports, reports)
      |> assign(:articles, articles)
      |> assign(:meta, meta)
      |> assign(:update, "replace")

    {:ok, socket}
  end

  # load articles on scroll
  @impl true
  def handle_event("load", %{"page" => page, "order" => order, "query" => query}, socket) do
    IO.puts("component #{socket.assigns.range} handling 'load'")
    sort_by = deserialize_sort_by(order)
    next_page = String.to_integer(page) + 1

    feed =
      socket.assigns.build
      |> Feed.search(query)
      |> Feed.page(next_page, sort_by)

    meta = feed.__meta__
    articles = UI.get_articles(feed)

    socket =
      socket
      |> assign(:meta, meta)
      |> assign(:articles, articles)
      |> assign(:update, "append")

    {:noreply, socket}
  end

  # sort and search
  @impl true
  def handle_event("filter", %{"order" => order, "query" => query}, socket) do
    IO.puts("component #{socket.assigns.range} handling 'filter'")
    sort_by = deserialize_sort_by(order)

    feed =
      socket.assigns.build
      |> Feed.search(query)
      |> Feed.page(0, sort_by)

    meta = feed.__meta__
    articles = UI.get_articles(feed)

    socket =
      socket
      |> assign(:meta, meta)
      |> assign(:articles, articles)
      |> assign(:update, "replace")

    {:noreply, socket}
  end

  # rebuild feed filtering by topics
  @impl true
  def handle_event("toggle_topic", %{"topic" => new_filter}, socket) do
    IO.puts("component #{socket.assigns.range} handling 'toggle_topic'")
    current_filter = get_filter(socket.assigns.build.__meta__)

    filter =
      case new_filter in current_filter do
        true -> List.delete(current_filter, new_filter)
        false -> [new_filter | current_filter]
      end

    build =
      socket.assigns.source
      |> Feed.source(socket.assigns.range)
      |> Feed.build(filter)

    topics = UI.get_topics(build)
    reports = UI.get_reports(build)

    feed = build |> Feed.page(0)
    meta = feed.__meta__
    articles = UI.get_articles(feed)

    socket =
      socket
      |> assign(:build, build)
      |> assign(:topics, topics)
      |> assign(:reports, reports)
      |> assign(:meta, meta)
      |> assign(:articles, articles)
      |> assign(:update, "replace")

    {:noreply, socket}
  end

  defp get_filter(meta) do
    meta
    |> Map.get(:filter, {:topics, []})
    |> elem(1)
  end

  defp serialize_sort_by(keyword) do
    case keyword do
      [desc: :date] -> "desc_date"
      [asc: :date] -> "asc_date"
      [desc: :views] -> "desc_views"
      [asc: :views] -> "asc_views"
    end
  end

  defp deserialize_sort_by(string) do
    case string do
      "desc_date" -> [desc: :date]
      "asc_date" -> [asc: :date]
      "desc_views" -> [desc: :views]
      "asc_views" -> [asc: :views]
    end
  end
end
