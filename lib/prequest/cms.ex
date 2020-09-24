defmodule Prequest.CMS do
  @moduledoc """
  A public API for managing content.
  """

  import Ecto.Query, warn: false
  alias Prequest.Repo
  alias Prequest.CMS.{Article, Report, Topic, User, View}

  @type article :: %Article{}
  @type user :: %User{}
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
  # users
  #

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @doc section: :user
  @spec get_user!(integer) :: user
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by its username.

  ## Examples

      iex> get_user("felipelincoln")
      %User{}

      iex> get_user("nonexistinguser")
      nil

  """
  @doc section: :user
  @spec get_user(String.t()) :: user
  def get_user(username), do: Repo.get_by(User, username: username)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{
        username: "felipelincoln",
        name: "Felipe de Souza Lincoln",
        bio: "this is my bio"
      })
      {:ok, %User{}}

      iex> create_user(%{})
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :user
  @spec create_user(map) :: {:ok, user} | {:error, changeset}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{bio: "updated bio"})
      {:ok, %User{}}

      iex> update_user(user, %{username: nil})
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :user
  @spec update_user(user, map) :: {:ok, user} | {:error, changeset}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :user
  @spec delete_user(user) :: {:ok, user} | {:error, changeset}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

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
  @doc section: :article
  @spec get_article!(integer) :: article
  def get_article!(id) do
    Repo.get!(Article, id)
  end

  @doc """
  Creates an article.

  ## Examples

      iex> create_article(%{
      ...>   title: "some title",
      ...>   source: "some github url",
      ...>   cover: "some image url",
      ...>   user_id: 10
      ...> })
      {:ok, %Article{}}

      iex> create_article(%{})
      {:error, %Ecto.Changeset{}}

  A `topics` key can be passed in the map input to associate topics with the article, whether it already
  exists or not.

      iex> create_article(%{
      ...>   title: "some title2",
      ...>   source: "some github url2",
      ...>   cover: "some image url2",
      ...>   user_id: 10,
      ...>   topics: [%{name: "elixir"}, %{name: "phoenix"}]
      ...> })
      {:ok, %Article{}}

  Once the topics named "elixir" and "phoenix" was created in the previous example, we can associate them again
  with a new article. We can proceed in two manners:

  * Get its struct from database and insert it into the topics list.
  * Pass the same map we used to create it.

  Let's use the "phoenix" topic in the former way and "elixir" in the latter.

      iex> topic = CMS.get_topic("phoenix")
      iex> create_article(%{
      ...>   title: "some title3",
      ...>   source: "some github url3",
      ...>   cover: "some image url3",
      ...>   user_id: 10,
      ...>   topics: [%{name: "elixir"}, topic]
      ...> })
      {:ok, %Article{}}

  """
  @doc section: :article
  @spec create_article(map) :: {:ok, article} | {:error, changeset}
  def create_article(attrs) do
    %Article{}
    |> Article.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topics, build_topics(attrs))
    |> Repo.insert()
  end

  @doc """
  Updates an article.

  ## Examples

      iex> update_article(article, %{title: "updated title"})
      {:ok, %Article{}}

      iex> update_article(article, %{source: nil})
      {:error, %Ecto.Changeset{}}

  When updating the topics do not forget to append the new one to the existing ones. Otherwise it will
  be replaced.

  > To see how the `topics` field works take a look at `create_article/1`

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
      {:ok,
        %Article{
          topics: [
            %Topic{name: "elixir"},
            %Topic{name: "ecto"},
            %Topic{name: "phoenix"}
          ],
          ...
        }
      }

  """
  @doc section: :article
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

  defp build_topic(%Topic{} = topic), do: topic

  defp build_topic(%{name: name}) do
    case Repo.get_by(Topic, name: name) do
      %Topic{} = topic -> topic
      nil -> %{name: name}
    end
  end

  @doc """
  Deletes an article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :article
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
  @doc section: :topic
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
  @doc section: :topic
  @spec create_topic(map) :: {:ok, topic} | {:error, changeset}
  def create_topic(attrs) do
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
  @doc section: :topic
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
  @doc section: :topic
  @spec delete_topic(topic) :: {:ok, topic} | {:error, changeset}
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  #
  # report
  #

  @doc """
  Gets a single report.

  Raises `Ecto.NoResultsError` if the Report does not exist.

  ## Examples

      iex> get_report!(123)
      %Report{}

      iex> get_report!(456)
      ** (Ecto.NoResultsError)

  """
  @doc section: :report
  @spec get_report!(integer) :: report
  def get_report!(id) do
    Repo.get!(Report, id)
  end

  @doc """
  Creates a report.

  ## Examples

      iex> create_report(%{user_id: 15, article_id: 3})
      {:ok, %Report{}}

      iex> create_report(%{})
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :report
  @spec create_report(map) :: {:ok, report} | {:error, changeset}
  def create_report(attrs) do
    %Report{}
    |> Report.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a report.

  ## Examples

      iex> update_report(report, %{message: "updated message"})
      {:ok, %Report{}}

      iex> update_report(report, %{article_id: nil})
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :report
  @spec update_report(report, map) :: {:ok, report} | {:error, changeset}
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
  @doc section: :report
  @spec delete_report(report) :: {:ok, report} | {:error, changeset}
  def delete_report(%Report{} = report) do
    Repo.delete(report)
  end

  #
  # view
  #

  @doc """
  Gets a single view.

  ## Examples

      iex> get_view(user.id, article.id)
      %View{}

      iex> get_view(0, 0)
      nil

  """
  @doc section: :view
  @spec get_view(integer, integer) :: view
  def get_view(user_id, article_id) do
    Repo.get_by(View, user_id: user_id, article_id: article_id)
  end

  @doc """
  Creates a view.

  ## Examples

      iex> create_view(%{user_id: 23, article_id: 12})
      {:ok, %View{}}

      iex> create_view(%{})
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :view
  @spec create_view(map) :: {:ok, view} | {:error, changeset}
  def create_view(attrs) do
    %View{}
    |> View.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a view.

  ## Examples

      iex> update_view(view, %{liked?: true})
      {:ok, %View{}}

      iex> update_view(view, %{article_id: nil})
      {:error, %Ecto.Changeset{}}

  """
  @doc section: :view
  @spec update_view(view, map) :: {:ok, view} | {:error, changeset}
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
  @doc section: :view
  @spec delete_view(view) :: {:ok, view} | {:error, changeset}
  def delete_view(%View{} = view) do
    Repo.delete(view)
  end
end
