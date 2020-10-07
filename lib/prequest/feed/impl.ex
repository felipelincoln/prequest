defmodule Prequest.Feed.Impl do
  @moduledoc false

  @type feed :: %Prequest.Feed{}

  @callback query(struct) :: feed
  @callback filter(feed, :topics, list) :: feed
  @callback build(feed) :: feed
  @callback view(feed, keyword) :: feed
  @callback load(feed) :: feed
end
