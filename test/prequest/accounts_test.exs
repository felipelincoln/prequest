defmodule Prequest.AccountsTest do
  use Prequest.DataCase, async: true

  alias Prequest.Accounts
  alias Prequest.Accounts.User
  alias Prequest.CMS

  # Testing
  # [x] Returning values
  # [x] Side effects
  # [x] Constraints
  # [x] Deletion effects

  describe "users" do
    @valid_attrs %{bio: "some bio", name: "some name", username: "some username"}
    @update_attrs %{
      bio: "some updated bio",
      name: "some updated name",
      username: "some updated username"
    }
    @invalid_attrs %{bio: nil, name: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user/1 returns the user with given username" do
      user = user_fixture()
      assert Accounts.get_user(user.username) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} =
               @valid_attrs
               |> Accounts.create_user()
               |> CMS.preload()

      assert user.bio == "some bio"
      assert user.name == "some name"
      assert user.username == "some username"

      assert user.articles == []
      assert user.reports == []
      assert user.views == []
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 using existing username returns error changeset" do
      assert {:ok, %User{}} = Accounts.create_user(@valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               %{username: @valid_attrs.username}
               |> Enum.into(@update_attrs)
               |> Accounts.create_user()
    end

    test "update_user/2 with valid data updates the user" do
      assert {:ok, %User{} = updated_user} =
               user_fixture()
               |> Accounts.update_user(@update_attrs)
               |> CMS.preload()

      assert updated_user.bio == @update_attrs.bio
      assert updated_user.name == @update_attrs.name
      assert updated_user.username == @update_attrs.username

      assert updated_user.articles == []
      assert updated_user.reports == []
      assert updated_user.views == []
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 using existing username returns error changeset" do
      user = user_fixture()
      new_user = user_fixture(%{username: @update_attrs.username})

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(new_user, %{username: user.username})
    end

    test "delete_user/1 deletes the user" do
      assert {:ok, %User{} = user} =
               user_fixture()
               |> Accounts.delete_user()

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "delete_user/1 releases username for a new use" do
      assert {:ok, %User{} = user} =
               user_fixture(%{username: "testing username"})
               |> Accounts.delete_user()

      assert %User{} = user_fixture(%{username: user.username})
    end

    test "delete_user/1 deletes owned articles and views" do
      user = user_fixture()

      {:ok, article} =
        CMS.create_article(%{
          title: "my article",
          cover: "my cover image",
          source: "my github markdown url",
          user_id: user.id
        })

      {:ok, _view} = CMS.create_view(%{user_id: user.id, article_id: article.id})

      {:ok, user} = Accounts.delete_user(user)

      assert CMS.get_view(user.id, article.id) == nil
      assert_raise Ecto.NoResultsError, fn -> CMS.get_article!(article.id) end
    end

    test "delete_user/1 preserves associated view" do
      user = user_fixture()
      new_user = user_fixture(@update_attrs)

      {:ok, article} =
        CMS.create_article(%{
          title: "my article",
          cover: "my cover image",
          source: "my github markdown url",
          user_id: user.id
        })

      {:ok, report} = CMS.create_report(%{user_id: new_user.id, article_id: article.id})

      {:ok, _new_user} = Accounts.delete_user(new_user)

      assert (%CMS.Report{} = report) = CMS.get_report!(report.id)
      assert report.user_id == nil
      assert report.article_id == article.id
    end
  end
end
