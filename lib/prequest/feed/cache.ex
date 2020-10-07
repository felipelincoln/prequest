defmodule Prequest.Feed.Cache do
  @moduledoc false

  alias Prequest.Feed
  alias Prequest.Feed.Cache.Server
  alias Prequest.Feed.Impl
  alias Prequest.Feed.Load

  @behaviour Impl

  @cache_expire_seconds 5

  def query(source), do: Load.query(source)
  def filter(%Feed{} = feed, :topics, values), do: Load.filter(feed, :topics, values)
  def build(%Feed{} = feed), do: load_or_cache(feed, &Load.build/1)
  def view(%Feed{} = feed, opts \\ []), do: Load.view(feed, opts)
  def load(%Feed{} = feed), do: load_or_cache(feed, &Load.load/1)

  defp load_or_cache(%Feed{query: query} = feed, load_callback) do
    case ets_read(query) do
      [] ->
        cache(feed, load_callback)

      [{^query, updated_at, cached_feed}] ->
        case has_expired?(updated_at) do
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
  defp ets_insert(entry), do: GenServer.cast(Server, {:insert, entry})

  defp has_expired?(datetime, expire_seconds \\ @cache_expire_seconds) do
    datetime
    |> DateTime.add(expire_seconds, :second)
    |> DateTime.compare(DateTime.utc_now())
    |> case do
      :gt -> false
      :lt -> true
    end
  end
end
