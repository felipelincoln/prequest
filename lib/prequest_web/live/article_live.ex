defmodule PrequestWeb.ArticleLive do
  @moduledoc false

  use PrequestWeb, :live_view
  alias PrequestWeb.ArticleLive.Core

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:content, Core.get_content(params))

    {:ok, socket}
  end
end
