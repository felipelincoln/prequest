defmodule Prequest.CMS.Article do
  @moduledoc """
  `Article` is the schema in the `CMS` context that model the articles.  

      schema "articles" do
        field :cover, :string
        field :source, :string
        field :title, :string

        timestamps()

        belongs_to :user, Accounts.User
        has_many :reports, Report
        has_many :views, View
        many_to_many :topics, Topic, join_through: "articles_topics"
      end
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Accounts
  alias Prequest.CMS.{Article, Report, Topic, View}

  schema "articles" do
    field :cover, :string
    field :source, :string
    field :title, :string

    timestamps()

    belongs_to :user, Accounts.User
    has_many :reports, Report
    has_many :views, View
    many_to_many :topics, Topic, join_through: "articles_topics"
  end

  @doc """
  Article's changeset.

  ## Validation
  Required: `:title`, `:cover`, `:source` and `user_id`.  
  Unique: `:source`.  

  ## Examples
  New article:

      iex> new_article = %{
      ...>   title: "Another title",
      ...>   source: "some_github_url",
      ...>   cover: "some_img_url",
      ...>   user_id: 1
      ...> }
      iex> changeset = Article.changeset(%Article{}, new_article)
      iex> Repo.insert(changeset)
      {:ok, %Article{}}
  """
  def changeset(%Article{} = article, attrs) do
    article
    |> cast(attrs, [:cover, :title, :source, :user_id])
    |> validate_required([:cover, :title, :source, :user_id])
    |> unique_constraint(:source)
    |> assoc_constraint(:user)
  end
end
