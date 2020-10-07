defmodule Prequest.FeedTest do
  use Prequest.DataCase, async: true

  import Prequest.Helpers
  alias Ecto.Adapters.SQL.Sandbox
  alias Prequest.Feed
  alias Prequest.Feed.{Cache, Load}
  alias Prequest.Manage

  # Testing
  # [ ] Returning values
  # [ ] Side effects
  # [ ] Deletion effects

  setup_all do
    Sandbox.mode(Prequest.Repo, :auto)
    {:ok, user} = Manage.create_user(%{username: "felipe"})

    {:ok, article0} =
      %{
        title: "article for testing feed",
        cover: "https://feedtest.com/cover.png",
        source: "https://github.com/feedtest/source.md",
        user_id: user.id
      }
      |> Manage.create_article()

    {:ok, topic} = Manage.create_topic(%{name: "feedtest"})

    {:ok, article1} =
      %{
        title: "article2 for testing feed",
        cover: "https://feedtest.com/cover2.png",
        source: "https://github.com/feedtest/source2.md",
        user_id: user.id,
        topics: [%{name: topic.name}]
      }
      |> Manage.create_article()

    on_exit(fn ->
      Sandbox.mode(Prequest.Repo, :auto)
      Manage.delete_user(user)
      Manage.delete_topic(topic)
    end)

    %{user: user, article0: article0, article1: article1, topic: topic}
  end

  describe "load" do
    test "query/1 returns the feed with an ecto query", %{user: user, topic: topic} do
      assert %Feed{query: %Ecto.Query{}} = Load.query(user)
      assert %Feed{query: %Ecto.Query{}} = Load.query(topic)
    end

    test "filter/3 returns the feed with an filtered ecto query", %{user: user} do
      feed = Load.query(user)

      assert %Feed{query: %Ecto.Query{} = query} =
               Load.query(user) |> Load.filter(:topics, ["it can be anything"])

      assert feed.query != query
    end

    test "build/1 returns a populated feed but keeps the ecto query", %{user: user, topic: topic} do
      old_feed = Load.query(user)
      assert (%Feed{} = feed) = old_feed |> Load.build()
      assert feed.query == old_feed.query
      assert feed.reports == []
      assert feed.topics == [{1, topic}]
      assert feed.__meta__.articles_count == 2
      assert feed.__meta__.topics_count == 1
    end

    test "view/3 returns the feed with metadata and paginated ecto query", %{user: user} do
      opts = [page: 0, per_page: 2]
      old_feed = Load.query(user) |> Load.build()
      assert (%Feed{} = feed) = old_feed |> Load.view(opts)
      assert feed.query != old_feed.query
      assert feed.__meta__.has_next? == false
      assert feed.__meta__.page == 0
      assert feed.__meta__.per_page == 2
    end

    test "view/3 sorted opt returns the feed with a sorted ecto query", %{user: user} do
      old_feed = Load.query(user) |> Load.build()
      assert (%Feed{} = feed_desc_date) = old_feed |> Load.view(sort_by: [desc: :date])
      assert (%Feed{} = feed_asc_date) = old_feed |> Load.view(sort_by: [asc: :date])
      assert (%Feed{} = feed_desc_views) = old_feed |> Load.view(sort_by: [desc: :views])
      assert (%Feed{} = feed_asc_views) = old_feed |> Load.view(sort_by: [asc: :views])

      assert feed_desc_date.query != feed_asc_date.query != feed_desc_views.query !=
               feed_asc_views.query
    end

    test "load/1 returns a feed with loaded articles but keeps the ecto query",
         %{user: user, article0: article0, article1: article1} do
      old_feed = Load.query(user) |> Load.build() |> Load.view()
      assert (%Feed{} = feed) = old_feed |> Load.load()
      assert feed.query == old_feed.query
      assert [article0, article1] -- preload!(feed.articles, :topics) == []
    end
  end

  # same as load for query/1, filter/3 and view/3
  describe "cache" do
    test "query/1 returns the feed with an ecto query", %{user: user, topic: topic} do
      assert %Feed{query: %Ecto.Query{}} = Cache.query(user)
      assert %Feed{query: %Ecto.Query{}} = Cache.query(topic)
    end

    test "filter/3 returns the feed with an filtered ecto query", %{user: user} do
      feed = Cache.query(user)

      assert %Feed{query: %Ecto.Query{} = query} =
               Cache.query(user) |> Cache.filter(:topics, ["it can be anything"])

      assert feed.query != query
    end

    test "build/1 returns a populated feed but keeps the ecto query", %{user: user, topic: topic} do
      old_feed = Cache.query(user)
      assert (%Feed{} = feed) = old_feed |> Cache.build(0)
      assert feed.query == old_feed.query
      assert feed.reports == []
      assert feed.topics == [{1, topic}]
      assert feed.__meta__.articles_count == 2
      assert feed.__meta__.topics_count == 1
    end

    # critical test
    test "build/1 caches the feed", %{user: user} do
      feed = Cache.query(user) |> Cache.build()
      assert [{_query, _datetime, cached_feed}] = :ets.lookup(:feed_cache, feed.query)
      assert feed == cached_feed

      new_feed = Cache.query(user) |> Cache.build(100)
      assert new_feed == cached_feed
    end

    test "view/3 returns the feed with metadata and paginated ecto query", %{user: user} do
      opts = [page: 0, per_page: 2]
      old_feed = Cache.query(user) |> Cache.build(0)
      assert (%Feed{} = feed) = old_feed |> Cache.view(opts)
      assert feed.query != old_feed.query
      assert feed.__meta__.has_next? == false
      assert feed.__meta__.page == 0
      assert feed.__meta__.per_page == 2
    end

    test "view/3 sorted opt returns the feed with a sorted ecto query", %{user: user} do
      old_feed = Cache.query(user) |> Cache.build(0)
      assert (%Feed{} = feed_desc_date) = old_feed |> Cache.view(sort_by: [desc: :date])
      assert (%Feed{} = feed_asc_date) = old_feed |> Cache.view(sort_by: [asc: :date])
      assert (%Feed{} = feed_desc_views) = old_feed |> Cache.view(sort_by: [desc: :views])
      assert (%Feed{} = feed_asc_views) = old_feed |> Cache.view(sort_by: [asc: :views])

      assert feed_desc_date.query != feed_asc_date.query != feed_desc_views.query !=
               feed_asc_views.query
    end

    test "load/1 returns a feed with loaded articles but keeps the ecto query",
         %{user: user, article0: article0, article1: article1} do
      old_feed = Cache.query(user) |> Cache.build(0) |> Cache.view()
      assert (%Feed{} = feed) = old_feed |> Cache.load(0)
      assert feed.query == old_feed.query
      assert [article0, article1] -- preload!(feed.articles, :topics) == []
    end

    # critical test
    test "load/1 caches the feed", %{user: user} do
      feed = Cache.query(user) |> Cache.build() |> Cache.view() |> Cache.load()
      assert [{_query, _datetime, cached_feed}] = :ets.lookup(:feed_cache, feed.query)
      assert feed == cached_feed

      new_feed = Cache.query(user) |> Cache.build(100) |> Cache.view() |> Cache.load()
      assert new_feed == cached_feed
    end
  end
end
