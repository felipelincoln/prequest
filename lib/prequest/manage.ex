defmodule Prequest.Manage do
  @moduledoc """
  A public API for managing content.
  """

  alias Prequest.Manage.{Article, Report, Topic, User, View}
  alias Prequest.Manage.{ArticleCRUD, ReportCRUD, TopicCRUD, UserCRUD, ViewCRUD}

  @type article :: %Article{}
  @type changeset :: %Ecto.Changeset{}
  @type report :: %Report{}
  @type topic :: %Topic{}
  @type user :: %User{}
  @type view :: %View{}

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
  def get_article!(id), do: ArticleCRUD.read!(id)

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

      iex> topic = Manage.get_topic("phoenix")
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
  def create_article(attrs), do: ArticleCRUD.create(attrs)

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

      iex> article |> Manage.Helpers.preload!(:topics)
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
  def update_article(article, attrs), do: ArticleCRUD.update(article, attrs)

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
  def delete_article(article), do: ArticleCRUD.delete(article)

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
  def get_report!(id), do: ReportCRUD.read!(id)

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
  def create_report(attrs), do: ReportCRUD.create(attrs)

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
  def update_report(report, attrs), do: ReportCRUD.update(report, attrs)

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
  def delete_report(report), do: ReportCRUD.delete(report)

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
  def get_topic(name), do: TopicCRUD.read(name)

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
  def create_topic(attrs), do: TopicCRUD.create(attrs)

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
  def update_topic(topic, attrs), do: TopicCRUD.update(topic, attrs)

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
  def delete_topic(topic), do: TopicCRUD.delete(topic)

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
  def get_user!(id), do: UserCRUD.read!(id)

  @doc """
  Gets a single user by its username.

  ## Examples

      iex> get_user("felipelincoln")
      %User{}

      iex> get_user("nonexistinguser")
      nil

  """
  @doc section: :user
  @spec get_user(String.t()) :: user | nil
  def get_user(username), do: UserCRUD.read(username)

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
  def create_user(attrs), do: UserCRUD.create(attrs)

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
  def update_user(user, attrs), do: UserCRUD.update(user, attrs)

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
  def delete_user(user), do: UserCRUD.delete(user)

  @doc """
  Gets a single view.

  ## Examples

      iex> get_view(user.id, article.id)
      %View{}

      iex> get_view(0, 0)
      nil

  """
  @doc section: :view
  @spec get_view(integer, integer) :: view | nil
  def get_view(user_id, article_id), do: ViewCRUD.read({user_id, article_id})

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
  def create_view(attrs), do: ViewCRUD.create(attrs)

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
  def update_view(view, attrs), do: ViewCRUD.update(view, attrs)

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
  def delete_view(view), do: ViewCRUD.delete(view)
end
