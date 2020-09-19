defmodule Prequest.CMSTest do
  use Prequest.DataCase, async: true

  alias Prequest.Accounts
  alias Prequest.CMS
  alias Prequest.CMS.{Article, Topic}

  setup_all do
    {:ok, user} = Accounts.create_user(%{username: "felipelincoln"})
    on_exit(fn -> Accounts.delete_user(user) end)

    %{user: user}
  end

  describe "articles" do
    @valid_attrs %{
      source: "some source",
      title: "some title",
      cover: "some cover",
      topics: ["topic1", "topic2", "topic3"]
    }

    @update_attrs %{
      source: "some updated source",
      title: "some updated title",
      cover: "some updated cover",
      topics: ["topic1.1", "topic2"]
    }
    @invalid_attrs %{source: nil, title: nil, cover: nil, user_id: nil}

    def article_fixture(%{user_id: _} = attrs) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CMS.create_article()

      article
    end

    test "get_article!/1 returns the article with given id", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      assert CMS.get_article!(article.id) |> CMS.preload_article!(:topics) == article
    end

    test "preload_article!/2 returns the article with preloaded field", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      fields = [:user, :reports, :views, :topics]

      assert (%Article{} = preloaded_article) = CMS.preload_article!(article, fields)
      assert preloaded_article.user == user
      assert preloaded_article.reports == []
      assert preloaded_article.views == []
      refute preloaded_article.topics == []
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
      refute CMS.preload_article!(article, :topics).topics == []
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs)
    end
  end
end
