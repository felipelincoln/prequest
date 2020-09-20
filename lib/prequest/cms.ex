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
  alias Prequest.CMS.{Article, Report, Topic, View}

  @type article :: %Article{}
  @type report :: %Report{}
  @type topic :: %Topic{}
  @type view :: %View{}
  @type changeset :: %Ecto.Changeset{}

  @doc """
  Preload fields from a schema's struct.

  Raises `ArgumentError` if the fields does not exist in the struct.

  ## Examples

      iex> user
      %User{} #=> articles: #Ecto.Association.NotLoaded<association :articles is not loaded>
      iex> preload!(user, :articles)
      %User{
        articles: [%Article{}, ...],
        ...
      }

      iex> article
      %Article{
        #=> reports: #Ecto.Association.NotLoaded<association :reports is not loaded>
        #=> views: #Ecto.Association.NotLoaded<association :views is not loaded>
      }
      iex> preload!(article, [:views, :reports])
      %Article{
        views: [%View{}, ...],
        reports: [%Report{}, ...],
        ...
      }

      iex> preload!(article, :field)
      ** (ArgumentError)
  """
  @spec preload!(struct, atom | [atom]) :: struct
  def preload!(content, fields) do
    Repo.preload(content, fields)
  end

  @doc """
  Preload all fields from a schema's struct inside a pipeline.

  ## Examples

  It can be used for `create_*` pipelines,

      iex> create_article(%{...})
      {:ok,
        %Article{
          #=> reports: #Ecto.Association.NotLoaded<association :reports is not loaded>
          #=> user: #Ecto.Association.NotLoaded<association :user is not loaded>
          #=> views: #Ecto.Association.NotLoaded<association :views is not loaded>
          ...
        }
      }

      iex> create_article(%{...}) |> preload()
      {:ok,
        %Article{
          reports: [%Report{}, ...],
          topics: [%Topic{}, ...],
          user: %User{},
          views: [%View{}, ...],
          ...
        }
      }

  and also `update_*` pipelines.

      iex> update_report(%{...})
      {:ok,
        %Report{
          #=> user: #Ecto.Association.NotLoaded<association :user is not loaded>
          #=> article: #Ecto.Association.NotLoaded<association :article is not loaded>
          ...
        }
      }

      iex> update_report(%{...}) |> preload()
      {:ok,
        %Report{
          user: %User{},
          article: %Article{},
          ...
        }
      }

  If the preceding changeset contain errors it does not do anything.

      iex> create_topic(%{name: nil}) |> preload()
      {:error, %Ecto.Changeset{}}

  """
  @spec preload({:ok, struct}) :: {:ok, struct}
  @spec preload({:error, changeset}) :: {:error, changeset}
  def preload({:ok, content}) do
    assoc = content.__struct__.__schema__(:associations)
    {:ok, preload!(content, assoc)}
  end

  def preload({:error, changeset}), do: {:error, changeset}

  #
  # articles
  #

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_article!(integer) :: article
  def get_article!(id) do
    Repo.get!(Article, id)
  end

  @doc """
  Creates an article.

  It inserts into the database a `Prequest.CMS.Article` struct with data populated through its changeset.

  ## Examples

      iex> create_article(%{
      ...>   title: "some title",
      ...>   source: "some github url",
      ...>   cover: "some image url",
      ...>   user_id: 10,
      ...>   topics: [%{name: "elixir"}, %{name: "phoenix"}]
      ...> }
      {:ok, %Article{}}

      iex> create_article(%{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_article(%{
          title: String.t(),
          source: String.t(),
          cover: String.t(),
          user_id: integer,
          topics: [%{name: String.t()} | topic] | nil
        }) :: {:ok, article} | {:error, changeset}
  def create_article(attrs) do
    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topics, build_topics(attrs))
    |> Repo.insert()
  end

  @doc """
  Updates an article.

  It updates an entry in the database for the `Prequest.CMS.Article` struct. The input data is validated
  through its changeset.

  ## Examples

      iex> update_article(article, %{title: "updated title"})
      {:ok, %Article{}}

      iex> update_article(article, %{source: nil})
      {:error, %Ecto.Changeset{}}

  When updating the topics do not forget to append the new one to the existing ones. Otherwise it will
  be replaced.

      iex> article |> CMS.preload!(:topics)
      %Article{
        topics: [
          %Topic{name: "elixir"},
          %Topic{name: "ecto"}
        ],
        ...
      }
      iex> {:ok, article} = update_article(article, %{topics: [%{name: "phoenix"}]})
      {:ok,
        %Article{
          topics: [%Topic{name: "phoenix"}],
          ...
        }
      }
      iex> update_article(article, %{topics: article.topics ++ [%{name: "elixir"}, %{name: "ecto"}]})
      %Article{
        topics: [
          %Topic{name: "elixir"},
          %Topic{name: "ecto"},
          %Topic{name: "phoenix"}
        ],
        ...
      }

  """
  @spec update_article(article, map) :: {:ok, article} | {:error, changeset}
  def update_article(%Article{} = article, %{topics: _} = attrs) do
    article
    |> preload!(:topics)
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topics, build_topics(attrs))
    |> Repo.update()
  end

  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  # Retrieve a topic struct from database if it exists, or a map otherwise.
  defp build_topics(%{topics: topics} = _attrs), do: Enum.map(topics, &build_topic/1)
  defp build_topics(_), do: []

  defp build_topic(%{name: name}) do
    case Repo.get_by(Topic, name: name) do
      %Topic{} = topic -> topic
      nil -> %{name: name}
    end
  end

  defp build_topic(%Topic{} = topic), do: topic
  defp build_topic(_), do: %{}

  @doc """
  Deletes an article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_article(article) :: {:ok, article} | {:error, changeset}
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  #
  # topic
  #

  @doc """
  Gets a single topic by its name.

  ## Examples

      iex> get_topic("elixir")
      %Topic{}

      iex> get_topic("")
      nil

  """
  @spec get_topic(String.t()) :: topic | nil
  def get_topic(name) do
    Repo.get_by(Topic, name: name)
  end

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{name: "new topic"})
      {:ok, %Topic{}}

      iex> create_topic(%{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_topic(%{name: String.t()}) :: {:ok, topic} | {:error, changeset}
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{name: "updated name"})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_topic(topic, map) :: {:ok, topic} | {:error, changeset}
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
  @spec delete_topic(topic) :: {:ok, topic} | {:error, changeset}
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end
end
