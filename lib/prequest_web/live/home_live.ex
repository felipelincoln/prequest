defmodule PrequestWeb.HomeLive do
  @moduledoc false

  use PrequestWeb, :live_view
  alias PrequestWeb.HomeLive.Core

  @flash_time 5000

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
    {status, msg} = Core.publish_article(url)

    Process.send_after(self(), :clear_flash, @flash_time)

    socket =
      socket
      |> clear_flash()
      |> put_flash(status, msg)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
