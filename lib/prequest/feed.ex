defmodule Prequest.Feed do
  @moduledoc """
  A public API for fetching feeds.

      iex> build(Article, ["elixir", "ecto"]) |> search("substring") |> page(20, [desc: :views])
      %Feed{...}
  """

  defstruct __meta__: %{}, query: nil, articles: [], reports: [], topics: []

  alias Prequest.Feed.{Cache, Load}

  def build(source) do
    source
    |> Cache.query()
    |> Cache.count(:ui_count)
    |> Cache.build()
  end

  def build(source, topics) when is_list(topics) do
    source
    |> Cache.query()
    |> Cache.filter(:topics, topics)
    |> Cache.count(:ui_count)
    |> Cache.build()
  end

  def search(feed, substring) do
    feed
    |> Load.search(substring)
    |> Load.count()
  end

  def page(feed, page), do: page(feed, page, desc: :date)

  def page(feed, page, [{order, key}]) do
    feed
    |> Cache.view(page: page, sort_by: [{order, key}])
    |> Cache.load()
  end

  def page(feed, :nocache, page, [{order, key}] \\ [desc: :date]) do
    feed
    |> Load.view(page: page, sort_by: [{order, key}])
    |> Load.load()
  end
end
