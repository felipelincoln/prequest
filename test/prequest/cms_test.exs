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
end
