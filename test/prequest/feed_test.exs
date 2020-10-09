defmodule Prequest.FeedTest do
  use Prequest.DataCase, async: true

  alias Ecto.Adapters.SQL.Sandbox
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

  test "build/1 returns the feed from given source" do
  end
end
