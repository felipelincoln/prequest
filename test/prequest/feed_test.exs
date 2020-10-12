defmodule Prequest.FeedTest do
  use Prequest.DataCase, async: true

  import Prequest.Helpers, only: [preload!: 2]
  alias Ecto.Adapters.SQL.Sandbox
  alias Prequest.Feed
  alias Prequest.Manage

  setup_all do
    Sandbox.mode(Prequest.Repo, :auto)

    # feed with 0 articles
    {:ok, user0} = Manage.create_user(%{username: "feedtest_felipelincoln0"})
    {:ok, topic0} = Manage.create_topic(%{name: "feedtest_topic0"})

    # feed with 1 article
    {:ok, user1} = Manage.create_user(%{username: "feedtest_felipelincoln1"})
    {:ok, topic1} = Manage.create_topic(%{name: "feedtest_topic1"})

    {:ok, _article} =
      %{
        title: "feedtest title1",
        cover: "https://prequest.com/feedtest_cover1.png",
        source: "https://github.com/feedtest_source1.md",
        user_id: user1.id,
        topics: [%{name: "feedtest_topic1"}]
      }
      |> Manage.create_article()

    # feed with n articles
    {:ok, usern} = Manage.create_user(%{username: "feedtest_felipelincolnn"})
    {:ok, topicn} = Manage.create_topic(%{name: "feedtest_topicn"})

    for n <- 2..20 do
      {:ok, _article} =
        %{
          title: "feedtest title#{n}",
          cover: "https://prequest.com/feedtest_cover#{n}.png",
          source: "https://github.com/feedtest_source#{n}.md",
          user_id: usern.id,
          topics: [
            %{name: "feedtest_topicn"},
            %{name: "feedtest_topic#{n}"},
            %{name: "feedtest_topic#{Enum.random(2..20)}"}
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

      for n <- 0..20 do
        Manage.get_topic("feedtest_topic#{n}") |> Manage.delete_topic()
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
      title_substring =
        user
        |> preload!(:articles)
        |> Map.get(:articles)
        |> List.first()
        |> Map.get(:title)
        |> String.slice(5, 5)

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

      reverse_substring = title_substring |> String.reverse()

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
end
