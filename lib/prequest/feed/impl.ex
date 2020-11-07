defmodule Prequest.Feed.Impl do
  @moduledoc false

  @type feed :: %Prequest.Feed{}
  @type ecto_query :: %Ecto.Query{}

  @callback source(struct | atom, integer) :: ecto_query
  @callback query(struct | atom | ecto_query) :: feed
  @callback filter(feed, :topics, list) :: feed
  @callback search(feed, String.t()) :: feed
  @callback build(feed) :: feed
  @callback view(feed, keyword) :: feed
  @callback load(feed) :: feed
end
