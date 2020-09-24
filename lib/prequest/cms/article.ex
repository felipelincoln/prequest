defmodule Prequest.CMS.Article do
  @moduledoc """
  The schema that models the article.

      schema "articles" do
        field :cover, :string
        field :source, :string
        field :title, :string

        timestamps()

        belongs_to :user, Accounts.User
        has_many :reports, Report
        has_many :views, View
        many_to_many :topics, Topic, join_through: "articles_topics", on_replace: :delete
      end

  Article is a content created by a user. 

  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.CMS.{Article, Report, Topic, User, View}

  schema "articles" do
    field :cover, :string
    field :source, :string
    field :title, :string

    timestamps()

    belongs_to :user, User
    has_many :reports, Report
    has_many :views, View
    many_to_many :topics, Topic, join_through: "articles_topics", on_replace: :delete
  end

  @doc """
  Article's changeset.

  ## Validation
  * Required: `:title`, `:cover`, `:source` and `user_id`.  
  * Unique: `:source`.  

  """
  def changeset(%Article{} = article, attrs) do
    article
    |> cast(attrs, [:cover, :title, :source, :user_id])
    |> validate_required([:cover, :title, :source, :user_id])
    |> unique_constraint(:source)
    |> assoc_constraint(:user)
  end
end
