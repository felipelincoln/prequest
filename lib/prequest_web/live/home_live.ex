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
    socket = assign(socket, build: build, feed: feed)
    {:ok, socket}
  end
end
