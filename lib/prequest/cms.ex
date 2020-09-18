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
  Preload fields from an article
  """
  def preload_article!(%Article{} = article, fields) do
    Repo.preload(article, fields)
  end

  @doc """
  Preload article's fields in a tuple pipeline
  """
  def preload_article({:ok, %Article{} = article}, fields) do
    {:ok, Repo.preload(article, fields)}
  end

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:articles, Article.changeset(%Article{}, attrs))
    |> Ecto.Multi.insert(:topics, Topic.changeset(%Topic{}, ))
    |> Repo.transaction()
  end


  alias Prequest.CMS.Topic

  @doc """
  """
  def get_or_create_topic(name) when is_binary(name) do
    case Repo.get_by Topic, name: name do
      %Topic{} = topic -> topic
      nil -> 
        %Topic{}
        |> Topic.changeset(%{name: name})
        |> Repo.insert()
    end
  end

  def get_or_create_topic(names) when is_list(names) do
    Enum.map(names, &get_or_create_topic/1)
  end










  ######################

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  alias Prequest.CMS.Report

  @doc """
  Returns the list of reports.

  ## Examples

      iex> list_reports()
      [%Report{}, ...]

  """
  def list_reports do
    Repo.all(Report)
  end

  @doc """
  Gets a single report.

  Raises `Ecto.NoResultsError` if the Report does not exist.

  ## Examples

      iex> get_report!(123)
      %Report{}

      iex> get_report!(456)
      ** (Ecto.NoResultsError)

  """
  def get_report!(id), do: Repo.get!(Report, id)

  @doc """
  Creates a report.

  ## Examples

      iex> create_report(%{field: value})
      {:ok, %Report{}}

      iex> create_report(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_report(attrs \\ %{}) do
    %Report{}
    |> Report.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a report.

  ## Examples

      iex> update_report(report, %{field: new_value})
      {:ok, %Report{}}

      iex> update_report(report, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_report(%Report{} = report, attrs) do
    report
    |> Report.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a report.

  ## Examples

      iex> delete_report(report)
      {:ok, %Report{}}

      iex> delete_report(report)
      {:error, %Ecto.Changeset{}}

  """
  def delete_report(%Report{} = report) do
    Repo.delete(report)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking report changes.

  ## Examples

      iex> change_report(report)
      %Ecto.Changeset{data: %Report{}}

  """
  def change_report(%Report{} = report, attrs \\ %{}) do
    Report.changeset(report, attrs)
  end

  alias Prequest.CMS.View

  @doc """
  Returns the list of view.

  ## Examples

      iex> list_view()
      [%View{}, ...]

  """
  def list_view do
    Repo.all(View)
  end

  @doc """
  Gets a single view.

  Raises `Ecto.NoResultsError` if the View does not exist.

  ## Examples

      iex> get_view!(123)
      %View{}

      iex> get_view!(456)
      ** (Ecto.NoResultsError)

  """
  def get_view!(id), do: Repo.get!(View, id)

  @doc """
  Creates a view.

  ## Examples

      iex> create_view(%{field: value})
      {:ok, %View{}}

      iex> create_view(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_view(attrs \\ %{}) do
    %View{}
    |> View.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a view.

  ## Examples

      iex> update_view(view, %{field: new_value})
      {:ok, %View{}}

      iex> update_view(view, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_view(%View{} = view, attrs) do
    view
    |> View.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a view.

  ## Examples

      iex> delete_view(view)
      {:ok, %View{}}

      iex> delete_view(view)
      {:error, %Ecto.Changeset{}}

  """
  def delete_view(%View{} = view) do
    Repo.delete(view)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking view changes.

  ## Examples

      iex> change_view(view)
      %Ecto.Changeset{data: %View{}}

  """
  def change_view(%View{} = view, attrs \\ %{}) do
    View.changeset(view, attrs)
  end

  alias Prequest.CMS.Topic

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics do
    Repo.all(Topic)
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{data: %Topic{}}

  """
  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end
end
