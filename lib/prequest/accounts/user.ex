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

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :name, :bio])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
