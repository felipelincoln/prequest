defmodule Prequest.CMSTest do
  use Prequest.DataCase

  alias Prequest.CMS

  describe "articles" do
    alias Prequest.Accounts.User
    alias Prequest.CMS.Article

    @valid_attrs %{source: "some source", title: "some title"}
    @update_attrs %{source: "some updated source", title: "some updated title"}
    @invalid_attrs %{source: nil, title: nil}
    @valid_user %User{username: "felipelincoln"}

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CMS.create_article(@valid_user)

      article
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()

      articles =
        CMS.list_articles()
        |> Enum.map(fn x -> x |> Repo.preload(:user) end)

      assert articles == [article]
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert CMS.get_article!(article.id) == article
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = CMS.create_article(@valid_attrs, @valid_user)
      assert article.source == "some source"
      assert article.title == "some title"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs, @valid_user)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = CMS.update_article(article, @update_attrs)
      assert article.source == "some updated source"
      assert article.title == "some updated title"
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
end
