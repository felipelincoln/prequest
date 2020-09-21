defmodule Prequest.CMSTest do
  use Prequest.DataCase, async: true

  alias Prequest.Accounts
  alias Prequest.CMS
  alias Prequest.CMS.{Article, Report, Topic}

  setup_all do
    {:ok, user} = Accounts.create_user(%{username: "felipelincoln"})

    {:ok, article} =
      %{title: "title", cover: "cover image", source: "github url", user_id: user.id}
      |> CMS.create_article()

    on_exit(fn ->
      Accounts.delete_user(user)
    end)

    %{user: user, article: article}
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

    test "create_article/1 with valid data creates an article", %{user: user} do
      assert {:ok, %Article{} = article} =
               %{user_id: user.id}
               |> Enum.into(@valid_attrs)
               |> CMS.create_article()

      assert article.source == @valid_attrs.source
      assert article.title == @valid_attrs.title
      assert article.cover == @valid_attrs.cover
      assert article.user_id == user.id

      assert article.topics ==
               Enum.map(@valid_attrs.topics, fn %{name: name} -> CMS.get_topic(name) end)
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs)

      # check if topics were not created.
      for %{name: name} <- @invalid_attrs.topics do
        assert CMS.get_topic(name) == nil
      end
    end

    test "update_article/2 with valid data updates the article", %{user: user} do
      assert {:ok, %Article{} = updated_article} =
               article_fixture(%{user_id: user.id})
               |> CMS.update_article(@update_attrs)

      assert updated_article.source == @update_attrs.source
      assert updated_article.title == @update_attrs.title
      assert updated_article.cover == @update_attrs.cover
      assert updated_article.user_id == user.id

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

      # check if article is still in sync with database.
      assert article == CMS.get_article!(article.id) |> CMS.preload!(:topics)

      # check if topics were not created.
      for %{name: name} <- @invalid_attrs.topics do
        assert CMS.get_topic(name) == nil
      end
    end

    test "delete_article/1 deletes the article", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      assert {:ok, %Article{}} = CMS.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_article!(article.id) end

      # check if replaced topics are not associated anymore.
      for %{name: name} <- @valid_attrs.topics do
        assert %Topic{articles: topic_articles} = CMS.get_topic(name) |> CMS.preload!(:articles)
        assert article not in topic_articles
      end
    end
  end

  describe "topics" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def topic_fixture do
      {:ok, topic} = CMS.create_topic(@valid_attrs)

      topic
    end

    test "get_topic/1 returns the topic with given name" do
      topic = topic_fixture()
      assert CMS.get_topic(topic.name) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      assert {:ok, %Topic{} = topic} = CMS.create_topic(@valid_attrs)
      assert topic.name == @valid_attrs.name
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{} = topic} = CMS.update_topic(topic, @update_attrs)
      assert topic.name == @update_attrs.name
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_topic(topic, @invalid_attrs)
      assert topic == CMS.get_topic(topic.name)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = CMS.delete_topic(topic)
      assert nil == CMS.get_topic(topic.name)
    end
  end

  describe "reports" do
    def report_fixture(%{user_id: _, article_id: _} = attrs) do
      {:ok, report} = CMS.create_report(attrs)

      report
    end

    test "get_report!/1 returns the report with given id", %{user: user, article: article} do
      report = report_fixture(%{user_id: user.id, article_id: article.id})
      assert CMS.get_report!(report.id) == report
    end

    test "create_report/1 with valid data creates a report", %{user: user, article: article} do
      attrs = %{user_id: user.id, article_id: article.id, message: "some message"}
      assert {:ok, %Report{} = report} = CMS.create_report(attrs)
      assert report.message == "some message"
    end

    test "create_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_report(%{})
    end

    test "update_report/2 with valid data updates the report", %{user: user, article: article} do
      report = report_fixture(%{article_id: article.id, user_id: user.id})

      assert {:ok, %Report{} = report} =
               CMS.update_report(report, %{user_id: nil, message: "some updated message"})

      assert report.message == "some updated message"
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
      report = report_fixture(%{user_id: user.id, article_id: article.id})
      assert {:ok, %Report{}} = CMS.delete_report(report)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_report!(report.id) end
    end
  end
end
