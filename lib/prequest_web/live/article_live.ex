defmodule PrequestWeb.ArticleLive do
  @moduledoc false

  use PrequestWeb, :live_view
  alias PrequestWeb.ArticleLive.Core

  @impl true
  def mount(params, _session, socket) do
    %{"article_id" => article_id, "username" => username} = params

    {:ok, socket}
  end
end
