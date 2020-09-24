defmodule Prequest.CMS.User do
  @moduledoc """
  The schema that models the user.

      schema "users" do
        field :bio, :string
        field :name, :string
        field :username, :string

        timestamps()

        has_many :articles, CMS.Article
        has_many :reports, CMS.Report
        has_many :views, CMS.View
      end

  Users are the one that create content to the platform.

  """

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

  @doc """
  User's changeset.

  ## Validation
  * Required: `username`.  
  * Unique: `username`.

  """
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :name, :bio])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
