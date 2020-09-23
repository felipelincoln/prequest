defmodule Prequest.CMSTest do
  use Prequest.DataCase, async: true

  alias Ecto.Adapters.SQL.Sandbox
  alias Prequest.Accounts
  alias Prequest.CMS
  alias Prequest.CMS.{Article, Report, Topic, View}

  # Testing
  # [x] Returning values
  # [x] Side effects
  # [x] Constraints
  # [x] Deletion effects

  setup_all do
    Sandbox.mode(Prequest.Repo, :auto)
    {:ok, user} = Accounts.create_user(%{username: "felipelincoln"})

    {:ok, article} =
      %{title: "title", cover: "cover image", source: "github url", user_id: user.id}
      |> CMS.create_article()

    {:ok, topic} = CMS.create_topic(%{name: "prequest"})

    on_exit(fn ->
      Sandbox.mode(Prequest.Repo, :auto)
      Accounts.delete_user(user)
      CMS.delete_topic(topic)
    end)

    %{user: user, article: article, topic: topic}
  end

  describe "articles" do
    @valid_attrs %{
      source: "some source",
      title: "some title",
      cover: "some cover",
      topics: [%{name: "topic1"}, %{name: "topic2"}]
    }

    @update_attrs %{
      source: "some updated source",
      title: "some updated title",
      cover: "some updated cover",
      topics: [%{name: "topic2"}, %{name: "topic3"}]
    }
    @invalid_attrs %{source: nil, title: nil, cover: nil, user_id: nil, topics: [%{name: ""}]}

    def article_fixture(%{user_id: _} = attrs) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CMS.create_article()

      article
    end

    test "get_article!/1 returns the article with given id", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      assert CMS.get_article!(article.id) |> CMS.preload!(:topics) == article
    end

    test "create_article/1 with valid data creates an article", %{user: user, topic: topic} do
      attrs = Map.merge(@valid_attrs, %{topics: [topic]}, fn _k, v1, v2 -> v1 ++ v2 end)

      assert {:ok, %Article{} = article} =
               %{user_id: user.id}
               |> Enum.into(attrs)
               |> CMS.create_article()
               |> CMS.preload()

      assert article.source == attrs.source
      assert article.title == attrs.title
      assert article.cover == attrs.cover
      assert article.user_id == user.id

      assert article.user == user
      assert article.reports == []
      assert article.views == []

      assert article.topics ==
               Enum.map(attrs.topics, fn %{name: name} -> CMS.get_topic(name) end)
    end

    test "create_article/1 with no topic associated creates an article", %{user: user} do
      # no :topics key
      assert {:ok, %Article{} = article_no_topics} =
               %{user_id: user.id}
               |> Enum.into(@valid_attrs)
               |> Map.delete(:topics)
               |> CMS.create_article()

      assert article_no_topics.topics == []

      # :topics as an empty list
      assert {:ok, %Article{} = article_empty_topics} =
               %{user_id: user.id, source: @valid_attrs.source <> "(1)"}
               |> Enum.into(@valid_attrs)
               |> Map.merge(%{topics: []}, fn _k, _v, v -> v end)
               |> CMS.create_article()

      assert article_empty_topics.topics == []
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs)

      # check if topics were not created.
      for %{name: name} <- @invalid_attrs.topics do
        assert CMS.get_topic(name) == nil
      end
    end

    test "create_article/1 using existing source returns error changeset", %{user: user} do
      assert {:ok, %Article{}} =
               %{user_id: user.id}
               |> Enum.into(@valid_attrs)
               |> CMS.create_article()

      assert {:error, %Ecto.Changeset{}} =
               %{user_id: user.id, source: @valid_attrs.source}
               |> Enum.into(@update_attrs)
               |> CMS.create_article()
    end

    test "update_article/2 with valid data updates the article", %{user: user} do
      assert {:ok, %Article{} = updated_article} =
               article_fixture(%{user_id: user.id})
               |> CMS.update_article(@update_attrs)
               |> CMS.preload()

      assert updated_article.source == @update_attrs.source
      assert updated_article.title == @update_attrs.title
      assert updated_article.cover == @update_attrs.cover
      assert updated_article.user_id == user.id

      assert updated_article.user == user
      assert updated_article.reports == []
      assert updated_article.views == []

      assert updated_article.topics ==
               Enum.map(@update_attrs.topics, fn %{name: name} -> CMS.get_topic(name) end)

      # check if replaced topics are not associated anymore.
      for %{name: name} <- @valid_attrs.topics -- @update_attrs.topics do
        assert %Topic{articles: topic_articles} = CMS.get_topic(name) |> CMS.preload!(:articles)
        assert updated_article not in topic_articles
      end
    end

    test "update_article/2 with invalid data returns error changeset", %{user: user} do
      article = article_fixture(%{user_id: user.id})

      assert {:error, %Ecto.Changeset{}} = CMS.update_article(article, @invalid_attrs)
      assert article == CMS.get_article!(article.id) |> CMS.preload!(:topics)

      # check if topics were not created.
      for %{name: name} <- @invalid_attrs.topics do
        assert CMS.get_topic(name) == nil
      end
    end

    test "update_article/1 using existing source returns error changeset", %{
      user: user,
      article: article
    } do
      new_article = article_fixture(%{user_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               CMS.update_article(new_article, %{source: article.source})
    end

    test "delete_article/1 deletes the article", %{user: user} do
      assert {:ok, %Article{} = article} =
               %{user_id: user.id}
               |> article_fixture
               |> CMS.delete_article()

      assert_raise Ecto.NoResultsError, fn -> CMS.get_article!(article.id) end

      # check if replaced topics are not associated anymore.
      for %{name: name} <- @valid_attrs.topics do
        assert %Topic{articles: topic_articles} = CMS.get_topic(name) |> CMS.preload!(:articles)
        assert article not in topic_articles
      end
    end

    test "delete_article/1 releases source for a new use", %{user: user} do
      assert {:ok, %Article{} = article} =
               %{user_id: user.id, source: "testing source"}
               |> article_fixture()
               |> CMS.delete_article()

      assert %Article{} = article_fixture(%{user_id: user.id, source: article.source})
    end

    test "delete_article/1 deletes all associated reports and views", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      {:ok, report} = CMS.create_report(%{article_id: article.id})
      {:ok, _view} = CMS.create_view(%{user_id: user.id, article_id: article.id})

      {:ok, article} = CMS.delete_article(article)

      assert_raise Ecto.NoResultsError, fn -> CMS.get_report!(report.id) end
      assert CMS.get_view(user.id, article.id) == nil
    end

    test "delete_article/1 preserves user and topics", %{user: user} do
      assert {:ok, %Article{} = article} =
               %{user_id: user.id}
               |> article_fixture
               |> CMS.delete_article()

      for %Topic{name: name} <- article.topics do
        assert %Topic{articles: topic_articles} = CMS.get_topic(name) |> CMS.preload!(:articles)
        assert article not in topic_articles
      end

      assert %Accounts.User{articles: user_articles} =
               Accounts.get_user!(user.id) |> CMS.preload!(:articles)

      assert article not in user_articles
    end
  end

  describe "topics" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def topic_fixture(attrs \\ @valid_attrs) do
      {:ok, topic} = CMS.create_topic(attrs)

      topic
    end

    test "get_topic/1 returns the topic with given name" do
      topic = topic_fixture()
      assert CMS.get_topic(topic.name) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      assert {:ok, %Topic{} = topic} =
               @valid_attrs
               |> CMS.create_topic()
               |> CMS.preload()

      assert topic.name == @valid_attrs.name
      assert topic.articles == []
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_topic(@invalid_attrs)
    end

    test "create_topic/1 using existing name returns error changeset" do
      assert {:ok, %Topic{}} = CMS.create_topic(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = CMS.create_topic(@valid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      assert {:ok, %Topic{} = topic} =
               topic_fixture()
               |> CMS.update_topic(@update_attrs)
               |> CMS.preload()

      assert topic.name == @update_attrs.name
      assert topic.articles == []
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_topic(topic, @invalid_attrs)
      assert topic == CMS.get_topic(topic.name)
    end

    test "update_topic/1 using existing name returns error changeset", %{topic: topic} do
      new_topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_topic(new_topic, %{name: topic.name})
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = CMS.delete_topic(topic)
      assert CMS.get_topic(topic.name) == nil
    end

    test "delete_topic/1 releases name for a new use" do
      assert {:ok, %Topic{} = topic} =
               %{name: "testing name"}
               |> topic_fixture()
               |> CMS.delete_topic()

      assert %Topic{} = topic_fixture(%{name: topic.name})
    end

    test "delete_topic/1 preserves articles", %{user: user} do
      topic = topic_fixture()

      {:ok, article} =
        CMS.create_article(%{
          title: "testing title",
          cover: "testing cover",
          source: "testing source",
          user_id: user.id,
          topics: [%{name: "a topic"}, topic]
        })

      assert {:ok, topic} = CMS.delete_topic(topic)

      assert %Article{topics: article_topics} =
               CMS.get_article!(article.id) |> CMS.preload!(:topics)

      assert topic not in article_topics
    end
  end

  describe "reports" do
    def report_fixture(%{article_id: _} = attrs) do
      {:ok, report} = CMS.create_report(attrs)

      report
    end

    test "get_report!/1 returns the report with given id", %{user: user, article: article} do
      report = report_fixture(%{user_id: user.id, article_id: article.id})
      assert CMS.get_report!(report.id) == report
    end

    test "create_report/1 with valid data creates a report", %{user: user, article: article} do
      assert {:ok, %Report{} = report} =
               %{user_id: user.id, article_id: article.id, message: "some message"}
               |> CMS.create_report()
               |> CMS.preload()

      assert report.message == "some message"
      assert report.user == user
      assert CMS.preload!(report.article, :topics) == article

      # article was created, so it will always have :topics loaded,
      # it's the create_article/1 behaviour.
      # On the other hand, report.article was obtained from database.

      assert {:ok, %Report{} = nouser_report} =
               %{article_id: article.id}
               |> CMS.create_report()
               |> CMS.preload()

      assert nouser_report.message == nil
      assert nouser_report.user == nil
      assert CMS.preload!(nouser_report.article, :topics) == article
    end

    test "create_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_report(%{})
    end

    test "update_report/2 with valid data updates the report", %{user: user, article: article} do
      assert {:ok, %Report{} = report} =
               report_fixture(%{article_id: article.id, user_id: user.id})
               |> CMS.update_report(%{user_id: nil, message: "some updated message"})
               |> CMS.preload()

      assert report.message == "some updated message"
      assert report.user == nil
      assert CMS.preload!(report.article, :topics) == article
    end

    test "update_report/2 with invalid data returns error changeset", %{
      user: user,
      article: article
    } do
      report = report_fixture(%{user_id: user.id, article_id: article.id})
      assert {:error, %Ecto.Changeset{}} = CMS.update_report(report, %{article_id: nil})
      assert report == CMS.get_report!(report.id)
    end

    test "delete_report/1 deletes the report", %{user: user, article: article} do
      assert {:ok, report} =
               %{user_id: user.id, article_id: article.id}
               |> report_fixture()
               |> CMS.delete_report()

      assert_raise Ecto.NoResultsError, fn -> CMS.get_report!(report.id) end
    end

    test "delete_report/1 preserves user and article", %{user: user, article: article} do
      assert {:ok, report} =
               %{user_id: user.id, article_id: article.id}
               |> report_fixture()
               |> CMS.delete_report()

      assert %Accounts.User{reports: user_reports} =
               Accounts.get_user!(user.id) |> CMS.preload!(:reports)

      assert report not in user_reports

      assert %Article{reports: article_reports} =
               CMS.get_article!(article.id) |> CMS.preload!(:reports)

      assert report not in article_reports
    end
  end

  describe "views" do
    def view_fixture(%{user_id: _, article_id: _} = attrs) do
      {:ok, view} = CMS.create_view(attrs)

      view
    end

    test "get_view/2 returns the view", %{user: user, article: article} do
      view = view_fixture(%{user_id: user.id, article_id: article.id})
      assert CMS.get_view(view.user_id, view.article_id) == view
    end

    test "create_view/1 with valid data creates a view", %{user: user, article: article} do
      assert {:ok, %View{} = view} =
               %{user_id: user.id, article_id: article.id, liked?: true}
               |> CMS.create_view()
               |> CMS.preload()

      assert view.liked? == true
      assert view.user == user
      assert CMS.preload!(view.article, :topics) == article
    end

    test "create_view/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_view(%{})
    end

    test "create_view/1 using existing user/article pair returns error changeset", %{
      user: user,
      article: article
    } do
      attrs = %{user_id: user.id, article_id: article.id}
      assert {:ok, %View{}} = CMS.create_view(attrs)
      assert {:error, %Ecto.Changeset{}} = CMS.create_view(attrs)
    end

    test "update_view/2 with valid data updates the view", %{user: user, article: article} do
      assert {:ok, %View{} = view} =
               view_fixture(%{article_id: article.id, user_id: user.id, liked?: false})
               |> CMS.update_view(%{liked?: true})
               |> CMS.preload()

      assert view.liked? == true
      assert view.user == user
      assert CMS.preload!(view.article, :topics) == article
    end

    test "update_view/2 with invalid data returns error changeset", %{
      user: user,
      article: article
    } do
      view = view_fixture(%{user_id: user.id, article_id: article.id})
      assert {:error, %Ecto.Changeset{}} = CMS.update_view(view, %{article_id: nil})
      assert view == CMS.get_view(user.id, article.id)
    end

    test "update_view/2 using existing user/article pair returns error changeset", %{
      user: user,
      article: article
    } do
      {:ok, new_user} = Accounts.create_user(%{username: "benicio"})
      _view = view_fixture(%{user_id: user.id, article_id: article.id})
      view = view_fixture(%{user_id: new_user.id, article_id: article.id})

      # `view` will be updated to have the same pair user/article as `_view`
      assert {:error, %Ecto.Changeset{}} = CMS.update_view(view, %{user_id: user.id})
    end

    test "delete_view/1 deletes the view", %{user: user, article: article} do
      assert {:ok, view} =
               %{user_id: user.id, article_id: article.id}
               |> view_fixture()
               |> CMS.delete_view()

      assert CMS.get_view(user.id, article.id) == nil
    end

    test "delete_view/1 releases article/user pair for a new user", %{
      user: user,
      article: article
    } do
      assert {:ok, view} =
               %{user_id: user.id, article_id: article.id}
               |> view_fixture()
               |> CMS.delete_view()

      assert %View{} = view_fixture(%{user_id: user.id, article_id: article.id})
    end

    test "delete_view/1 preserves user and article", %{user: user, article: article} do
      assert {:ok, view} =
               %{user_id: user.id, article_id: article.id}
               |> view_fixture()
               |> CMS.delete_view()

      assert %Accounts.User{views: user_views} =
               Accounts.get_user!(user.id) |> CMS.preload!(:views)

      assert view not in user_views

      assert %Article{views: article_views} = CMS.get_article!(article.id) |> CMS.preload!(:views)

      assert view not in article_views
    end
  end
end
