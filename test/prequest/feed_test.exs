defmodule Prequest.FeedTest do
  use Prequest.DataCase, async: true

  alias Ecto.Adapters.SQL.Sandbox
  alias Prequest.Feed
  alias Prequest.Manage

  @username "feedtest_felipelincoln"
  @topic "feedtest_topic"
  @a_title "feedtest title"
  @a_cover "https://prequest.com/feedtest_cover"
  @a_source "https://github.com/feedtest_source"

  defp username(k), do: @username <> to_string(k)
  defp topic(k), do: @topic <> to_string(k)
  defp a_title(k), do: @a_title <> to_string(k)
  defp a_cover(k), do: @a_cover <> to_string(k)
  defp a_source(k), do: @a_source <> to_string(k)

  setup_all do
    Sandbox.mode(Prequest.Repo, :auto)

    # feed with 0 articles
    {:ok, user0} = Manage.create_user(%{username: username(0)})
    {:ok, topic0} = Manage.create_topic(%{name: topic(0)})

    # feed with 1 article
    {:ok, user1} = Manage.create_user(%{username: username(1)})
    {:ok, topic1} = Manage.create_topic(%{name: topic(1)})

    {:ok, _article} =
      %{
        title: a_title(1),
        cover: a_cover(1),
        source: a_source(1),
        user_id: user1.id,
        topics: [topic1]
      }
      |> Manage.create_article()

    # feed with n articles
    {:ok, usern} = Manage.create_user(%{username: username("n")})
    {:ok, topicn} = Manage.create_topic(%{name: topic("n")})

    for n <- 2..21 do
      {:ok, _article} =
        %{
          title: a_title(n),
          cover: a_cover(n),
          source: a_source(n),
          user_id: usern.id,
          topics: [
            topicn,
            %{name: topic(n)}
          ]
        }
        |> Manage.create_article()
    end

    # cleaning prequest_test database
    on_exit(fn ->
      Sandbox.mode(Prequest.Repo, :auto)
      Manage.delete_user(user0)
      Manage.delete_user(user1)
      Manage.delete_user(usern)
      Manage.delete_topic(topicn)

      for n <- 0..21 do
        Manage.get_topic(topic(n)) |> Manage.delete_topic()
      end
    end)

    %{
      user0: user0,
      topic0: topic0,
      user1: user1,
      topic1: topic1,
      usern: usern,
      topicn: topicn
    }
  end

  describe "feed containing no articles" do
    test "build/1 returns the feed from given source", %{user0: user, topic0: topic} do
      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user)

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic)
    end

    test "build/2 returns the feed from given source and topics", %{user0: user, topic0: topic} do
      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["anything"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user, ["anything"])

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["anything"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic, ["anything"])
    end

    test "search/2 returns the feed containing searched articles", %{user0: user, topic0: topic} do
      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 results: 0,
                 search: "substring",
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user) |> Feed.search("substring")

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 results: 0,
                 search: "substring",
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic) |> Feed.search("substring")
    end

    test "page/3 returns the feed with preloaded articles", %{user0: user, topic0: topic} do
      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 has_next?: false,
                 page: 0,
                 results: 0,
                 sort_by: [desc: :date],
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user) |> Feed.page(0)

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 has_next?: false,
                 page: 0,
                 results: 0,
                 sort_by: [desc: :date],
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic) |> Feed.page(0)

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 has_next?: false,
                 page: 1,
                 results: 0,
                 sort_by: [desc: :date],
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user) |> Feed.page(1)

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 has_next?: false,
                 page: 1,
                 results: 0,
                 sort_by: [desc: :date],
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic) |> Feed.page(1)

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 has_next?: false,
                 page: 0,
                 results: 0,
                 sort_by: [desc: :views],
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user) |> Feed.page(0, desc: :views)

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 has_next?: false,
                 page: 0,
                 results: 0,
                 sort_by: [desc: :views],
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic) |> Feed.page(0, desc: :views)
    end
  end

  describe "feed containing 1 article" do
    test "build/1 returns the feed from given source", %{user1: user, topic1: topic} do
      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 results: 1,
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(user)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 results: 1,
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(topic)
    end

    test "build/2 returns the feed from given source and topics", %{
      user1: user,
      topic1: %{name: name} = topic
    } do
      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 filter: {:topics, [^name]},
                 results: 1,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user, [name])

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 filter: {:topics, [^name]},
                 results: 1,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic, [name])

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["_"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user, ["_"])

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["_"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic, ["_"])
    end

    test "search/2 returns the feed containing searched articles", %{user1: user, topic1: topic} do
      title_substring = String.slice(@a_title, 5, 5)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 results: 1,
                 search: ^title_substring,
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(user) |> Feed.search(title_substring)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 results: 1,
                 search: ^title_substring,
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(topic) |> Feed.search(title_substring)

      reverse_substring = String.reverse(title_substring)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 results: 0,
                 search: ^reverse_substring,
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(user) |> Feed.search(reverse_substring)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 results: 0,
                 search: ^reverse_substring,
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(topic) |> Feed.search(reverse_substring)
    end

    test "page/3 returns the feed with preloaded articles", %{user1: user, topic1: topic} do
      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 has_next?: false,
                 page: 0,
                 results: 1,
                 sort_by: [desc: :date],
                 topics_count: 1
               },
               articles: [%Manage.Article{}],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(user) |> Feed.page(0)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 has_next?: false,
                 page: 0,
                 results: 1,
                 sort_by: [desc: :date],
                 topics_count: 1
               },
               articles: [%Manage.Article{}],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(topic) |> Feed.page(0)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 has_next?: false,
                 page: 1,
                 results: 1,
                 sort_by: [desc: :date],
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(user) |> Feed.page(1)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 has_next?: false,
                 page: 1,
                 results: 1,
                 sort_by: [desc: :date],
                 topics_count: 1
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(topic) |> Feed.page(1)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 has_next?: false,
                 page: 0,
                 results: 1,
                 sort_by: [desc: :views],
                 topics_count: 1
               },
               articles: [%Manage.Article{}],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(user) |> Feed.page(0, desc: :views)

      assert %Feed{
               __meta__: %{
                 articles_count: 1,
                 has_next?: false,
                 page: 0,
                 results: 1,
                 sort_by: [desc: :views],
                 topics_count: 1
               },
               articles: [%Manage.Article{}],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, ^topic}]
             } = Feed.build(topic) |> Feed.page(0, desc: :views)
    end
  end

  describe "feed containing n article" do
    test "build/1 returns the feed from given source", %{usern: user, topicn: topic} do
      assert %Feed{
               __meta__: a_meta,
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(Manage.Article)

      assert a_meta.articles_count >= 21
      assert a_meta.results >= 21
      assert a_meta.topics_count >= 41

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 results: 20,
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(user)

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 results: 20,
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(topic)
    end

    test "build/2 returns the feed from given source and topics", %{
      usern: user,
      topicn: %{name: name} = topic
    } do
      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 filter: {:topics, [^name]},
                 results: 20,
                 topics_count: 20
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, a_topic} | _topics]
             } = Feed.build(Manage.Article, [name])

      assert a_topic != topic

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 filter: {:topics, [^name]},
                 results: 20,
                 topics_count: 20
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, u_topic} | _topics]
             } = Feed.build(user, [name])

      assert u_topic != topic

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 filter: {:topics, [^name]},
                 results: 20,
                 topics_count: 20
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{1, t_topic} | _topics]
             } = Feed.build(topic, [name])

      assert t_topic != topic

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["_"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(Manage.Article, ["_"])

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["_"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(user, ["_"])

      assert %Feed{
               __meta__: %{
                 articles_count: 0,
                 filter: {:topics, ["_"]},
                 results: 0,
                 topics_count: 0
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: []
             } = Feed.build(topic, ["_"])
    end

    test "search/2 returns the feed containing searched articles", %{usern: user, topicn: topic} do
      title_substring = @a_title <> "10"

      assert %Feed{
               __meta__: a_meta,
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(Manage.Article) |> Feed.search(title_substring)

      assert a_meta.articles_count >= 21
      assert a_meta.topics_count >= 41
      assert a_meta.results == 1
      assert a_meta.search == title_substring

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 results: 1,
                 search: ^title_substring,
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(user) |> Feed.search(title_substring)

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 results: 1,
                 search: ^title_substring,
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(topic) |> Feed.search(title_substring)

      reverse_substring = String.reverse(title_substring)

      assert %Feed{
               __meta__: ra_meta,
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(Manage.Article) |> Feed.search(reverse_substring)

      assert ra_meta.articles_count >= 21
      assert ra_meta.topics_count >= 41
      assert ra_meta.results == 0
      assert ra_meta.search == reverse_substring

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 results: 0,
                 search: ^reverse_substring,
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(user) |> Feed.search(reverse_substring)

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 results: 0,
                 search: ^reverse_substring,
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(topic) |> Feed.search(reverse_substring)
    end

    # caution: this test depends on feed default parameters
    test "page/3 returns the feed with preloaded articles", %{usern: user, topicn: topic} do
      assert %Feed{
               __meta__: a_meta,
               articles: [%Manage.Article{} | _articles],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(Manage.Article) |> Feed.page(0)

      assert a_meta.articles_count >= 21
      assert a_meta.results >= 21
      assert a_meta.topics_count >= 41
      assert a_meta.has_next? == true
      assert a_meta.page == 0
      assert a_meta.sort_by == [desc: :date]

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 has_next?: true,
                 page: 0,
                 results: 20,
                 sort_by: [desc: :date],
                 topics_count: 40
               },
               articles: [%Manage.Article{} | _articles],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(user) |> Feed.page(0)

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 has_next?: true,
                 page: 0,
                 results: 20,
                 sort_by: [desc: :date],
                 topics_count: 40
               },
               articles: [%Manage.Article{} | _articles],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(topic) |> Feed.page(0)

      assert %Feed{
               __meta__: a_meta_mil,
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(Manage.Article) |> Feed.page(1000)

      assert a_meta_mil.articles_count >= 21
      assert a_meta_mil.results >= 21
      assert a_meta_mil.topics_count >= 41
      assert a_meta_mil.has_next? == false
      assert a_meta_mil.page == 1000
      assert a_meta_mil.sort_by == [desc: :date]

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 has_next?: false,
                 page: 1000,
                 results: 20,
                 sort_by: [desc: :date],
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(user) |> Feed.page(1000)

      assert %Feed{
               __meta__: %{
                 articles_count: 20,
                 has_next?: false,
                 page: 1000,
                 results: 20,
                 sort_by: [desc: :date],
                 topics_count: 40
               },
               articles: [],
               query: %Ecto.Query{},
               reports: [],
               topics: [{20, ^topic} | _topics]
             } = Feed.build(topic) |> Feed.page(1000)
    end
  end

  describe "feed caching" do
    test "build/2 caches the feed", %{usern: user, topicn: topic} do
      feed = Feed.build(user, [topic.name])
      query = feed.query

      assert [{^query, datetime, ^feed}] = :ets.lookup(:feed_cache, feed.query)

      # get from cache
      cached_feed = Feed.build(user, [topic.name])
      assert [{^query, ^datetime, ^feed}] = :ets.lookup(:feed_cache, cached_feed.query)
    end

    test "page/3 caches build and page layer", %{usern: user, topicn: topic} do
      build = Feed.build(user, [topic.name])
      b_query = build.query

      page = build |> Feed.page(0)
      p_query = page.query

      assert [{^b_query, b_datetime, ^build}] = :ets.lookup(:feed_cache, build.query)
      assert [{^p_query, p_datetime, ^page}] = :ets.lookup(:feed_cache, page.query)

      # get from cache
      cached_build = Feed.build(user, [topic.name])
      cached_page = cached_build |> Feed.page(0)
      assert [{^b_query, ^b_datetime, ^build}] = :ets.lookup(:feed_cache, cached_build.query)
      assert [{^p_query, ^p_datetime, ^page}] = :ets.lookup(:feed_cache, cached_page.query)
    end

    test "page/4 caches only the build layer", %{usern: user} do
      build = Feed.build(user)
      query = build.query

      page = build |> Feed.search("not used substring") |> Feed.page(0, :nocache)

      assert [{^query, _datetime, ^build}] = :ets.lookup(:feed_cache, build.query)
      assert [] = :ets.lookup(:feed_cache, page.query)
    end

    test "Cache.build/2 caches when expired", %{usern: user} do
      build = Feed.Cache.query(user) |> Feed.Cache.build(0)
      query = build.query

      assert [{^query, datetime, ^build}] = :ets.lookup(:feed_cache, build.query)

      # cache again (expire_secs=0)
      build_2 = Feed.Cache.query(user) |> Feed.Cache.build(0)

      assert [{^query, datetime_2, ^build}] = :ets.lookup(:feed_cache, build_2.query)
      assert DateTime.compare(datetime_2, datetime) == :gt
    end
  end
end
