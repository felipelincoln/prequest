defmodule Prequest.CMSTest do
  use Prequest.DataCase

  alias Prequest.Accounts
  alias Prequest.CMS

  describe "articles" do
    alias Prequest.CMS.Article

    @valid_attrs %{source: "some source", title: "some title", cover: "some cover"}
    @update_attrs %{
      source: "some updated source",
      title: "some updated title",
      cover: "some updated cover"
    }
    @invalid_attrs %{source: nil, title: nil, cover: nil, user_id: nil}

    def user_id do
      {:ok, user} = Accounts.create_user(%{username: "felipelincoln"})
      user.id
    end

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Map.merge(%{user_id: user_id()})
        |> Enum.into(@valid_attrs)
        |> CMS.create_article()

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      articles = CMS.list_articles()

      assert articles == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert CMS.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      attrs = Map.merge(@valid_attrs, %{user_id: user_id()})
      assert {:ok, %Article{} = article} = CMS.create_article(attrs)
      assert article.source == "some source"
      assert article.title == "some title"
      assert article.cover == "some cover"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = CMS.update_article(article, @update_attrs)
      assert article.source == "some updated source"
      assert article.title == "some updated title"
      assert article.cover == "some updated cover"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_article(article, @invalid_attrs)
      assert article == CMS.get_article!(article.id)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = CMS.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = CMS.change_article(article)
    end
  end

  describe "reports" do
    alias Prequest.CMS.Report

    @valid_attrs %{message: "some message"}
    @update_attrs %{message: "some updated message"}
    @invalid_attrs %{article_id: nil}

    def article_id do
      {:ok, user} = Accounts.create_user(%{username: "felipelincoln"})

      {:ok, article} =
        CMS.create_article(%{title: "a", cover: "a", source: "a", user_id: user.id})

      article.id
    end

    def report_fixture(attrs \\ %{}) do
      {:ok, report} =
        attrs
        |> Map.merge(%{article_id: article_id()})
        |> Enum.into(@valid_attrs)
        |> CMS.create_report()

      report
    end

    test "list_reports/0 returns all reports" do
      report = report_fixture()
      assert CMS.list_reports() == [report]
    end

    test "get_report!/1 returns the report with given id" do
      report = report_fixture()
      assert CMS.get_report!(report.id) == report
    end

    test "create_report/1 with valid data creates a report" do
      attrs = Map.merge(@valid_attrs, %{article_id: article_id()})
      assert {:ok, %Report{} = report} = CMS.create_report(attrs)
      assert report.message == "some message"
    end

    test "create_report/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_report(@invalid_attrs)
    end

    test "update_report/2 with valid data updates the report" do
      report = report_fixture()
      assert {:ok, %Report{} = report} = CMS.update_report(report, @update_attrs)
      assert report.message == "some updated message"
    end

    test "update_report/2 with invalid data returns error changeset" do
      report = report_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_report(report, @invalid_attrs)
      assert report == CMS.get_report!(report.id)
    end

    test "delete_report/1 deletes the report" do
      report = report_fixture()
      assert {:ok, %Report{}} = CMS.delete_report(report)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_report!(report.id) end
    end

    test "change_report/1 returns a report changeset" do
      report = report_fixture()
      assert %Ecto.Changeset{} = CMS.change_report(report)
    end
  end

  describe "view" do
    alias Prequest.CMS.View

    @valid_attrs %{liked?: true}
    @update_attrs %{liked?: false}
    @invalid_attrs %{article_id: nil, user_id: nil}

    def id_map do
      {:ok, user} = Accounts.create_user(%{username: "felipelincoln"})

      {:ok, article} =
        CMS.create_article(%{title: "a", cover: "a", source: "a", user_id: user.id})

      %{user_id: user.id, article_id: article.id}
    end

    def view_fixture(attrs \\ %{}) do
      {:ok, view} =
        attrs
        |> Map.merge(id_map())
        |> Enum.into(@valid_attrs)
        |> CMS.create_view()

      view
    end

    test "list_view/0 returns all view" do
      view = view_fixture()
      assert CMS.list_view() == [view]
    end

    test "get_view!/1 returns the view with given id" do
      view = view_fixture()
      assert CMS.get_view!(view.id) == view
    end

    test "create_view/1 with valid data creates a view" do
      attrs = Map.merge(@valid_attrs, id_map())
      assert {:ok, %View{} = view} = CMS.create_view(attrs)
      assert view.liked? == true
    end

    test "create_view/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_view(@invalid_attrs)
    end

    test "update_view/2 with valid data updates the view" do
      view = view_fixture()
      assert {:ok, %View{} = view} = CMS.update_view(view, @update_attrs)
      assert view.liked? == false
    end

    test "update_view/2 with invalid data returns error changeset" do
      view = view_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_view(view, @invalid_attrs)
      assert view == CMS.get_view!(view.id)
    end

    test "delete_view/1 deletes the view" do
      view = view_fixture()
      assert {:ok, %View{}} = CMS.delete_view(view)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_view!(view.id) end
    end

    test "change_view/1 returns a view changeset" do
      view = view_fixture()
      assert %Ecto.Changeset{} = CMS.change_view(view)
    end
  end

  describe "topics" do
    alias Prequest.CMS.Topic

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def topic_fixture(attrs \\ %{}) do
      {:ok, topic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CMS.create_topic()

      topic
    end

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert CMS.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert CMS.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      assert {:ok, %Topic{} = topic} = CMS.create_topic(@valid_attrs)
      assert topic.name == "some name"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{} = topic} = CMS.update_topic(topic, @update_attrs)
      assert topic.name == "some updated name"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = CMS.update_topic(topic, @invalid_attrs)
      assert topic == CMS.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = CMS.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = CMS.change_topic(topic)
    end
  end
end
