defmodule Prequest.CMS.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.CMS.{Article, Report, User, View}

  schema "users" do
    field :bio, :string
    field :name, :string
    field :username, :string

    timestamps()

    has_many :articles, Article
    has_many :reports, Report
    has_many :views, View
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :name, :bio])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
