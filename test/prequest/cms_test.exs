defmodule Prequest.CMSTest do
  use Prequest.DataCase, async: true

  alias Prequest.Accounts
  alias Prequest.CMS
  alias Prequest.CMS.Article

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
      topics: ["topic1", "topic2"]
    }

    @update_attrs %{
      source: "some updated source",
      title: "some updated title",
      cover: "some updated cover",
      topics: ["topic2", "topic3"]
    }
    @invalid_attrs %{source: nil, title: nil, cover: nil, user_id: nil, topics: [""]}

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
               |> CMS.preload()

      assert article.source == @valid_attrs.source
      assert article.title == @valid_attrs.title
      assert article.cover == @valid_attrs.cover
      assert article.user_id == user.id
      refute article.topics == []
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs)
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

      assert MapSet.new(@update_attrs.topics) ==
               updated_article.topics
               |> Enum.map(fn topic -> topic.name end)
               |> MapSet.new()

      removed_topic =
        (@valid_attrs.topics -- @update_attrs.topics)
        |> hd
        |> CMS.get_topic()
        |> CMS.preload!(:articles)

      assert removed_topic.articles == []
    end

    test "update_article/2 with invalid data returns error changeset", %{user: user} do
      article = article_fixture(%{user_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               article
               |> CMS.update_article(@invalid_attrs)
               |> CMS.preload()

      assert article == CMS.get_article!(article.id) |> CMS.preload!(:topics)
    end

    test "delete_article/1 deletes the article", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      assert {:ok, %Article{}} = CMS.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_article!(article.id) end
    end
  end
end
