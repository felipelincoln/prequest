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
      topics: [%{name: "topic1"}, %{name: "topic2"}]
    }

    @update_attrs %{
      source: "some updated source",
      title: "some updated title",
      cover: "some updated cover",
      topics: [%{name: "topic2"}, %{name: "topic3"}]
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

      for %{name: name} <- @valid_attrs.topics do
        assert %Topic{} = CMS.get_topic(name)
      end
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CMS.create_article(@invalid_attrs)

      for name <- @invalid_attrs.topics do
        assert CMS.get_topic(name) == nil
      end
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
               |> Enum.map(fn topic -> %{name: topic.name} end)
               |> MapSet.new()

      for %{name: name} <- @valid_attrs.topics ++ @update_attrs.topics do
        assert %Topic{} = CMS.get_topic(name)
      end

      for %{name: name} <- @valid_attrs.topics -- @update_attrs.topics do
        removed_topic =
          name
          |> CMS.get_topic()
          |> CMS.preload!(:articles)

        assert removed_topic.articles == []
      end
    end

    test "update_article/2 with invalid data returns error changeset", %{user: user} do
      article = article_fixture(%{user_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               article
               |> CMS.update_article(@invalid_attrs)
               |> CMS.preload()

      assert article == CMS.get_article!(article.id) |> CMS.preload!(:topics)

      for name <- @invalid_attrs.topics do
        assert CMS.get_topic(name) == nil
      end
    end

    test "delete_article/1 deletes the article", %{user: user} do
      article = article_fixture(%{user_id: user.id})
      assert {:ok, %Article{}} = CMS.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> CMS.get_article!(article.id) end

      for %{name: name} <- @valid_attrs.topics do
        assert %Topic{} = CMS.get_topic(name)
      end
    end
  end
end
