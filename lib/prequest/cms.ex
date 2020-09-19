defmodule Prequest.CMS do
  @moduledoc """
  The `CMS` context is the interface between user calls and the `Repo`.

  # Use cases
  We are to create two users, one will post an article and the other will interact with this article.  
  Let's start by creating the users using the `Prequest.Accounts` context real quick.

      iex> {:ok, felipe} = Accounts.create_user %{username: "felipe"}
      iex> {:ok, lincoln} = Accounts.create_user %{username: "lincoln"}

  Back to our `CMS` context. Let's create an article and associate it to `felipe`

      iex> {:ok, article} = CMS.create_article %{
      ...>   title: "some title", 
      ...>   cover: "some cover",
      ...>   source: "some github url",
      ...>   user_id: felipe.id
      ...> }

  Now let's make `lincoln` read and like this article

      iex> CMS.create_view %{
      ...>   liked?: true,
      ...>   user_id: lincoln.id,
      ...>   article_id: article.id
      ...> }

  An annonymous user reads this article and finds a typo, let's report that

      iex> CMS.create_report %{
      ...>   article_id: article.id,
      ...>   message: "There is some typo"
      ...> }

  Let's take a look at this article now

      iex> CMS.get_article!(article.id) |> Repo.preload([:user, :reports, :views])
      %Prequest.CMS.Article{
        __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
        cover: "some cover",
        id: 3,
        inserted_at: ~N[2020-09-17 11:19:05],
        reports: [
          %Prequest.CMS.Report{
            __meta__: #Ecto.Schema.Metadata<:loaded, "reports">,
            article: #Ecto.Association.NotLoaded<association :article is not loaded>,
            article_id: 3,
            id: 1,
            inserted_at: ~N[2020-09-17 11:21:59],
            message: "There is some typo",
            updated_at: ~N[2020-09-17 11:21:59],
            user: #Ecto.Association.NotLoaded<association :user is not loaded>,
            user_id: nil
          }
        ],
        source: "some github url",
        title: "some title",
        topics: #Ecto.Association.NotLoaded<association :topics is not loaded>,
        updated_at: ~N[2020-09-17 11:19:05],
        user: %Prequest.Accounts.User{
          __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
          articles: #Ecto.Association.NotLoaded<association :articles is not loaded>,
          bio: nil,
          id: 2,
          inserted_at: ~N[2020-09-17 11:16:44],
          name: nil,
          reports: #Ecto.Association.NotLoaded<association :reports is not loaded>,
          updated_at: ~N[2020-09-17 11:16:44],
          username: "felipe",
          views: #Ecto.Association.NotLoaded<association :views is not loaded>
        },
        user_id: 2,
        views: [
          %Prequest.CMS.View{
            __meta__: #Ecto.Schema.Metadata<:loaded, "view">,
            article: #Ecto.Association.NotLoaded<association :article is not loaded>,
            article_id: 3,
            id: 3,
            inserted_at: ~N[2020-09-17 11:20:43],
            liked?: true,
            updated_at: ~N[2020-09-17 11:20:43],
            user: #Ecto.Association.NotLoaded<association :user is not loaded>,
            user_id: 3
          }
        ]
      }
  """

  import Ecto.Query, warn: false
  alias Prequest.Repo

  alias Prequest.CMS.Article

  @doc false
  def list_articles do
    Repo.all(Article)
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id) do
    Repo.get!(Article, id)
  end

  @doc """
  Preload fields from an article.

  Raises `ArgumentError` if `fields` does not exist in `%Article{}`.

  ## Examples

      iex> preload_article!(article, :topics)
      %Article{}

      iex> preload_article!(article, [:views, :reports])
      %Article{}

      iex> preload_article!(article, :field)
      ** (ArgumentError)
  """
  def preload_article!(%Article{} = article, fields) do
    Repo.preload(article, fields)
  end

  @doc """
  Creates an article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topics, build_topics(attrs))
    |> Repo.insert()
  end

  alias Prequest.CMS.Topic

  # Retrieve a topic struct from database if it exists, or a map otherwise.
  defp build_topics(%{topics: names} = _attrs) do
    Enum.map(names, fn name ->
      case Repo.get_by(Topic, name: name) do
        %Topic{} = topic -> topic
        nil -> %{name: name}
      end
    end)
  end

  defp build_topics(_attrs), do: []
end
