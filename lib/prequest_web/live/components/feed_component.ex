defmodule PrequestWeb.Components.FeedComponent do
  @moduledoc false

  use Phoenix.LiveComponent
  alias PrequestWeb.Components.FeedComponent.API
  alias PrequestWeb.Components.FeedComponent.Core

  @impl true
  def mount(socket) do
    IO.puts("component mounted")
    {:ok, socket, temporary_assigns: [articles: nil]}
  end

  @impl true
  def update(params, socket) do
    %{id: id, source: source, range: range, query: query, sort_by_latest?: sort_by_latest?} =
      params

    sort_by = Core.sort_key(sort_by_latest?)

    {build, topics, reports} = Core.create_build(source, range, [])
    {meta, articles} = Core.create_feed(build, query, 0, sort_by)

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
    {meta, articles} = Core.create_feed(build, query, Core.next_page(page), sort_by)

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

    {build, topics, reports} =
      Core.create_build(source, range, Core.apply_filter(meta, new_filter))

    {meta, articles} = Core.create_feed(build, query, 0, sort_by)

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
end
