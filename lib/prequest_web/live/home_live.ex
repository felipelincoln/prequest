defmodule PrequestWeb.HomeLive do
  @moduledoc """
  Homepage
  """

  use PrequestWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="px-8 py-12">
      <h1 class="text-indigo-500 text-5xl font-bold text-center">homepage</h1>
    <div class="w-64 bg-indigo-500 text-white p-5 rounded font-semibold">
    <p class="truncate">Running a phoenix application inside a docker container</p></div>
    </div>
    """
  end
end
