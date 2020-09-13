defmodule Prequest.Accounts.User do
  @moduledoc """
  `User` is the schema in the `Accounts` context that model the users.  

      schema "users" do
        field :bio, :string
        field :name, :string
        field :username, :string

        timestamps()

        has_many :articles, Article
      end
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Accounts.User
  alias Prequest.CMS.Article

  schema "users" do
    field :bio, :string
    field :name, :string
    field :username, :string

    timestamps()

    has_many :articles, Article
  end

  @doc """
  User's changeset.

  # Validation
  Required: `username`.  
  Unique: `username`.

  # Examples
  New user:
      iex> new_user = %{username: "felipelincoln"}
      iex> changeset = User.changeset(%User{}, new_user)
      iex> Repo.insert(changeset)
      {:ok, %User{}}

  """
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :name, :bio])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
