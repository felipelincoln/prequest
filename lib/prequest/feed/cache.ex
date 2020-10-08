defmodule Prequest.Feed.Cache do
  @moduledoc false

  alias Prequest.Feed
  alias Prequest.Feed.Cache.Server
  alias Prequest.Feed.Impl
  alias Prequest.Feed.Load

  @behaviour Impl

  @expire_sec 5

  def query(source), do: Load.query(source)
  def filter(feed, :topics, values), do: Load.filter(feed, :topics, values)
  def search(feed, substring), do: Load.search(feed, substring)
  def count(feed, count_name \\ :articles_count), do: Load.count(feed, count_name)
  def build(feed, expire_sec \\ @expire_sec), do: load_or_cache(feed, &Load.build/1, expire_sec)
  def view(feed, opts \\ []), do: Load.view(feed, opts)
  def load(feed, expire_sec \\ @expire_sec), do: load_or_cache(feed, &Load.load/1, expire_sec)

  defp load_or_cache(%Feed{query: query} = feed, load_callback, expire_sec) do
    case ets_read(query) do
      [] ->
        cache(feed, load_callback)

      [{^query, updated_at, cached_feed}] ->
        case has_expired?(updated_at, expire_sec) do
          true -> cache(feed, load_callback)
          false -> cached_feed
        end
    end
  end

  defp cache(%Feed{query: query} = feed, callback) do
    loaded_feed = callback.(feed)
    ets_insert({query, DateTime.utc_now(), loaded_feed})
    loaded_feed
  end

  defp ets_read(key), do: GenServer.call(Server, {:read, key})
  defp ets_insert(entry), do: GenServer.call(Server, {:insert, entry})

  defp has_expired?(datetime, expire_sec) do
    datetime
    |> DateTime.add(expire_sec, :second)
    |> DateTime.compare(DateTime.utc_now())
    |> case do
      :gt -> false
      :lt -> true
    end
  end
end
