defmodule PrequestWeb.HomeLive do
  @moduledoc """
  Homepage
  """

  use PrequestWeb, :live_view
  alias Prequest.Feed
  alias Prequest.Manage.Article

  def mount(_params, _session, socket) do
    build = Feed.build(Article)
    feed = build |> Feed.page(0)
    socket =
      socket
      |> assign(build: build, feed: feed)
      |> assign(ui_topics: ui_topics(feed))

    {:ok, socket}
  end

  defp ui_topics(%Feed{topics: topics, __meta__: %{topics_count: count}}) do
    Enum.map(topics, fn {n, topic} -> {n/count*100, topic.name} end)
  end
end
