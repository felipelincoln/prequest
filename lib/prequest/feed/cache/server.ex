defmodule Prequest.Feed.Cache.Server do
  @moduledoc false

  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  # Server callbacks

  def init(state) do
    :ets.new(:feed_cache, [:named_table])
    {:ok, state}
  end

  def handle_call({:insert, entry}, _from, state) do
    value = :ets.insert(:feed_cache, entry)
    {:reply, value, state}
  end

  def handle_call({:read, key}, _from, state) do
    value = :ets.lookup(:feed_cache, key)
    {:reply, value, state}
  end
end
