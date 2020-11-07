defmodule PrequestWeb.FeedComponent do
  @moduledoc """
  The component for feed
  """

  use Phoenix.LiveComponent
  alias Prequest.Feed

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [feed: nil]}
  end

  @impl true
  def update(%{id: id, source: source, range: range}, socket) do
    build =
      source
      |> Feed.source(range)
      |> Feed.build()

    feed = build |> Feed.page(0)

    socket =
      socket
      |> assign(:id, id)
      |> assign(:source, source)
      |> assign(:range, range)
      |> assign(:build, build)
      |> assign(:feed, feed)
      |> assign(:update, "replace")

    {:ok, socket}
  end

  # load articles on scroll
  @impl true
  def handle_event("load", %{"page" => page, "order" => order, "query" => query}, socket) do
    sort_by = deserialize_sort_by(order)
    next_page = String.to_integer(page) + 1

    feed =
      socket.assigns.build
      |> Feed.search(query)
      |> Feed.page(next_page, sort_by)

    socket =
      socket
      |> assign(:feed, feed)
      |> assign(:update, "append")

    {:noreply, socket}
  end

  # sort and search
  @impl true
  def handle_event("filter", %{"order" => order, "query" => query}, socket) do
    sort_by = deserialize_sort_by(order)

    feed =
      socket.assigns.build
      |> Feed.search(query)
      |> Feed.page(0, sort_by)

    socket =
      socket
      |> assign(:feed, feed)
      |> assign(:update, "replace")

    {:noreply, socket}
  end

  # rebuild feed filtering by topics
  @impl true
  def handle_event("toggle_topic", %{"topic" => new_filter}, socket) do
    current_filter = get_filter(socket.assigns.build)

    filter =
      case new_filter in current_filter do
        true -> List.delete(current_filter, new_filter)
        false -> [new_filter | current_filter]
      end

    build =
      socket.assigns.source
      |> Feed.source(socket.assigns.range)
      |> Feed.build(filter)

    feed = build |> Feed.page(0)

    socket =
      socket
      |> assign(:build, build)
      |> assign(:feed, feed)
      |> assign(:update, "replace")

    {:noreply, socket}
  end

  defp get_filter(feed) do
    feed.__meta__
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
