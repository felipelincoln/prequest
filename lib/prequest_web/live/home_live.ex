defmodule PrequestWeb.HomeLive do
  @moduledoc """
  Homepage
  """

  use PrequestWeb, :live_view

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
    {:noreply, assign(socket, :query, query)}
  end

  @impl true
  def handle_event("toggle-sort", _params, socket) do
    {:noreply, assign(socket, :sort_by_latest?, !socket.assigns.sort_by_latest?)}
  end
end
