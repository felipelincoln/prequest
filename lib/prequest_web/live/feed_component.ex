defmodule PrequestWeb.FeedComponent do
  @moduledoc false

  use Phoenix.LiveComponent
  alias Prequest.Feed
  alias PrequestWeb.FeedComponent.UI

  @impl true
  def mount(socket) do
    IO.puts("component mounted")
    {:ok, socket, temporary_assigns: [articles: nil]}
  end

  @impl true
  def update(params, socket) do
    %{id: id, source: source, range: range, query: query, sort_by_latest?: sort_by_latest?} =
      params

    sort_by = sort_key(sort_by_latest?)

    {build, topics, reports} = create_build(source, range, [])
    {meta, articles} = create_feed(build, query, 0, sort_by)

    socket =
      socket
      |> assign(:id, id)
      |> assign(:source, source)
      |> assign(:range, range)
      |> assign(:query, query)
      |> assign(:sort_by_latest?, sort_by_latest?)
      |> assign(:sort_by, sort_by)
      |> assign(:build, build)
      |> assign(:topics, topics)
      |> assign(:reports, reports)
      |> assign(:meta, meta)
      |> assign(:articles, articles)
      |> assign(:update, "replace")

    IO.puts("component #{range} updated")
    {:ok, socket}
  end

  # load articles on scroll
  @impl true
  def handle_event("load", %{"page" => page}, socket) do
    %{build: build, sort_by: sort_by, query: query} = socket.assigns
    {meta, articles} = create_feed(build, query, next_page(page), sort_by)

    socket =
      socket
      |> assign(:meta, meta)
      |> assign(:articles, articles)
      |> assign(:update, "append")

    IO.puts("component #{socket.assigns.range} handling 'load'")
    {:noreply, socket}
  end

  # rebuild feed filtering by topics
  @impl true
  def handle_event("toggle_topic", %{"topic" => new_filter}, socket) do
    %{meta: meta, source: source, range: range, query: query, sort_by: sort_by} = socket.assigns
    {build, topics, reports} = create_build(source, range, apply_filter(meta, new_filter))
    {meta, articles} = create_feed(build, query, 0, sort_by)

    socket =
      socket
      |> assign(:build, build)
      |> assign(:topics, topics)
      |> assign(:reports, reports)
      |> assign(:meta, meta)
      |> assign(:articles, articles)
      |> assign(:update, "replace")

    IO.puts("component #{socket.assigns.range} handling 'toggle_topic'")
    {:noreply, socket}
  end

  defp create_build(source, range, filter) do
    build =
      source
      |> Feed.source(range)
      |> Feed.build(filter)

    {build, UI.get_topics(build), UI.get_reports(build)}
  end

  defp create_feed(build, query, page, sort_by) do
    feed =
      build
      |> Feed.search(query)
      |> Feed.page(page, sort_by)

    {feed.__meta__, UI.get_articles(feed)}
  end

  defp apply_filter(meta, new_filter) do
    current_filter = get_filter(meta)

    case new_filter in current_filter do
      true -> List.delete(current_filter, new_filter)
      false -> [new_filter | current_filter]
    end
  end

  defp get_filter(meta) do
    meta
    |> Map.get(:filter, {:topics, []})
    |> elem(1)
  end

  defp sort_key(true), do: [desc: :date]
  defp sort_key(false), do: [desc: :views]

  defp next_page(page_str), do: String.to_integer(page_str) + 1
end
