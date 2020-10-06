defmodule Prequest.Blog.Feed do
  @moduledoc false

  defstruct __meta__: %{}, query: nil, articles: [], reports: [], topics: []

  alias Prequest.Blog.Feed

  @type feed :: %Feed{}

  @callback query(struct) :: feed
  @callback filter(feed, :topics, list) :: feed
  @callback build(feed) :: feed
  @callback view(feed, keyword) :: feed
end
