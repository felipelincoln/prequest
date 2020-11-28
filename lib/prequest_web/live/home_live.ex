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
      |> assign(:publish_article_url, "")
      |> assign(:sort_by_latest?, false)
      |> assign(:feed_id, "feed0")

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

    # reset url in the sucessful case
    publish_article_url =
      case status do
        :info -> ""
        :error -> url
      end

    # flush send_after
    if :flash_timer_pid in Map.keys(socket.assigns) do
      Process.cancel_timer(socket.assigns.flash_timer_pid)
    end

    # update id to reload component
    feed_id =
      if status == :error do
        socket.assigns.feed_id
      else
        socket.assigns.feed_id <> "a"
      end

    # remove flash after a timer
    flash_timer_pid = Process.send_after(self(), :clear_flash, @flash_time)

    socket =
      socket
      |> clear_flash()
      |> put_flash(status, msg)
      |> assign(:publish_article_url, publish_article_url)
      |> assign(:flash_timer_pid, flash_timer_pid)
      |> assign(:feed_id, feed_id)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
