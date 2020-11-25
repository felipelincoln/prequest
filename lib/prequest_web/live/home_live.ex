defmodule PrequestWeb.HomeLive do
  @moduledoc false

  use PrequestWeb, :live_view
  alias PrequestWeb.HomeLive.Core

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:query, "")
      |> assign(:sort_by_latest?, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    case String.trim(query) do
      "" -> {:noreply, assign(socket, :query, "")}
      text -> {:noreply, assign(socket, :query, text)}
    end
  end

  @impl true
  def handle_event("toggle-sort", _params, socket) do
    {:noreply, assign(socket, :sort_by_latest?, !socket.assigns.sort_by_latest?)}
  end

  @impl true
  def handle_event("publish", %{"url" => url}, socket) do
    {status, msg} = Core.new_article(url)

    socket =
      socket
      |> clear_flash()
      |> put_flash(status, msg)

    {:noreply, socket}
  end
end
