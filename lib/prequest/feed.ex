defmodule Prequest.Feed do
  @moduledoc """
  A public API for fetching feeds.
  """

  @doc """
  Struct for modeling a feed.

  It contains a metadata field, which describes

  * `articles_count` : how many articles the `build/2` alone was able to fetch.
  * `results` : how many articles the `search/2` got. It evaluates the same as `articles_count` if there is
  no `search/2` in the pipeline.
  * `filter` : what topics was selected from `build/2`. Articles in a feed contains all the topics listed here.
  * `topics_count` : the count of all topics for all articles (be it a distinct topic or not).
  * `search` : the substring used in `search/2`.
  * `page` : current feed page.
  * `per_page` : amount of articles to show each page.
  * `has_next?` : if there is articles in the next page.

  and also the fields

  * `query` : an ecto query that is executed by `page/4` to fetch articles from database or cache.
  * `articles` : a list of articles.
  * `reports` : a list of reports from all articles.
  * `topics` : a list of tuples `{count, topic}`, being `count` the amount of articles that have this `topic`.

  `topics_count` is the sum of `count` in all `{count, topic}`.


  ## Example

      iex> build(Article, ["otp"]) |> search("prequest") |> page(0)
      %Prequest.Feed{
        __meta__: %{
          articles_count: 234,
          filter: {:topics, ["otp"]},
          has_next?: true,
          page: 0,
          per_page: 10,
          results: 56,
          search: "prequest",
          topics_count: 178
        },
        articles: [
          %Prequest.Manage.Article{ ... },
          %Prequest.Manage.Article{ ... },
          ...
        ],
        query: # Ecto.Query<from a0 in Prequest.Manage.Article, as: :articles,
               # join: t1 in assoc(a0, :topics), where: t1.name in ^["otp"],
               # where: ilike(a0.title, ^"%prequest%"), group_by: [a0.id],
               # having: count(t1.id, :distinct) == ^1, order_by: [desc: a0.updated_at],
               # limit: ^2, offset: ^0, select: a0>,
        reports: [],
        topics: [
          {34, %Prequest.Manage.Topic{ ... }},
          {15, %Prequest.Manage.Topic{ ... }},
          ...
        ]
      }

  """
  defstruct __meta__: %{}, query: nil, articles: [], reports: [], topics: []

  alias Prequest.Feed
  alias Prequest.Feed.{Cache, Load}

  @type feed :: %Feed{}
  @type ecto_query :: %Ecto.Query{}

  @doc """
  no docs yet
  """
  @spec source(struct | atom, integer) :: ecto_query
  def source(source, n) do
    source
    |> Cache.source(n)
  end

  @doc """
  Populate a feed struct with all information but articles.

  ## Examples
  To get a feed from all the articles

      iex> build(Article)
      %Prequest.Feed{
        __meta__: %{articles_count: 1234, results: 1234, topics_count: 1567},
        articles: [],
        query: # Ecto.Query<from a0 in Prequest.Manage.Article, as: :articles, select: a0>,
        reports: [
          %Prequest.Manage.Report{ ... },
          %Prequest.Manage.Report{ ... },
          ...
        ],
        topics: [
          {89, %Prequest.Manage.Topic{ ... }},
          {12, %Prequest.Manage.Topic{ ... }},
          ...
        ]
      }

  or from a specific topic / user

      iex> topic = Manage.get_topic("elixir")
      iex> build(topic)
      %Feed{ ... }

      iex> user = Manage.get_user("felipelincoln")
      iex> build(user)
      %Feed{ ... }

  """
  @spec build(struct | atom | ecto_query) :: feed
  def build(source) do
    source
    |> Cache.query()
    |> Cache.build()
  end

  @doc """
  Same as `build/1` but adding a topics filter to the ecto query.

  The filtering will make the query match only articles that contain all the topics listed.

  ## Example

      iex> build(Article, ["elixir", "otp"])
      %Prequest.Feed{
        __meta__: %{
          articles_count: 123,
          filter: {:topics, ["elixir", "otp"]},
          results: 123,
          topics_count: 145
        },
        articles: [],
        query: # Ecto.Query<from a0 in Prequest.Manage.Article, as: :articles,
               # join: t1 in assoc(a0, :topics), where: t1.name in ^["otp"],
               # group_by: [a0.id], having: count(t1.id, :distinct) == ^1, select: a0>,
        reports: [],
        topics: [
          {67, %Prequest.Manage.Topic{ ... }},
          {54, %Prequest.Manage.Topic{ ... }},
          ...
        ]
      }
  """
  @spec build(struct | atom | ecto_query, list) :: feed
  def build(source, topics) when is_list(topics) do
    source
    |> Cache.query()
    |> Cache.filter(:topics, topics)
    |> Cache.build()
  end

  @doc """
  Returns the feed adding a search expression to the ecto query.

  ## Examples

      iex> build(Article) |> search("prequest")
      %Prequest.Feed{
        __meta__: %{
          articles_count: 107,
          results: 23,
          search: "prequest",
          topics_count: 160
        },
        articles: [],
        query: # Ecto.Query<from a0 in Prequest.Manage.Article, as: :articles,
               # where: ilike(a0.title, ^"%prequest%"), select: a0>,
        reports: [
          %Prequest.Manage.Report{ ... },
          %Prequest.Manage.Report{ ... },
          ...
        ],
        topics: [
          {78, %Prequest.Manage.Topic{ ... }},
          {45, %Prequest.Manage.Topic{ ... }},
          ...
        ]
      }

  """
  @spec search(feed, String.t()) :: feed
  def search(feed, substring) do
    feed
    |> Cache.search(substring)
  end

  @doc """
  Returns the feed with the articles field populated

  ## Examples

      iex> build(Article, ["otp"]) |> page(0)
      %Prequest.Feed{
        __meta__: %{
          articles_count: 67,
          filter: {:topics, ["otp"]},
          has_next?: true,
          page: 0,
          per_page: 10,
          results: 67,
          topics_count: 189
        },
        articles: [
          %Prequest.Manage.Article{ ... },
          %Prequest.Manage.Article{ ... },
          ...
        ],
        query: # Ecto.Query<from a0 in Prequest.Manage.Article, as: :articles,
               # join: t1 in assoc(a0, :topics), where: t1.name in ^["otp"],
               # where: ilike(a0.title, ^"%prequest%"), group_by: [a0.id],
               # having: count(t1.id, :distinct) == ^1, order_by: [desc: a0.updated_at],
               # limit: ^2, offset: ^0, select: a0>,
        reports: [],
        topics: [
          {45, %Prequest.Manage.Topic{ ... }},
          {32, %Prequest.Manage.Topic{ ... }},
          ...
        ]
      }

  """
  @spec page(feed, integer) :: feed
  def page(feed, page), do: page(feed, page, desc: :date)

  @doc """
  Same as `page/2` but ordering by date or views.

  ## Examples

      iex> build(Article) |> page(0, [desc: :date])
      iex> build(Article) |> page(0, [asc: :date])
      iex> build(Article) |> page(0, [desc: :views])
      iex> build(Article) |> page(0, [asc: :views])

  """
  @spec page(feed, integer, keyword) :: feed
  def page(feed, page, [{order, key}]) do
    feed
    |> Cache.view(page: page, sort_by: [{order, key}])
    |> Cache.load()
  end

  @doc """
  Same as `page/3` but with no caching on pages layer (to be used with `search/2`).

  Since almost every search query is unique among users, it is not ideal to keep a copy of this specific feed
  into the server's RAM. The caching on the `build` stage still occurs though.

  ## Examples

      iex> build(Article, ["ecto"]) |> search("prequest") |> page(0, :nocache, [desc: :views])
      %Prequest.Feed{
        __meta__: %{
          has_next?: true,
          page: 0,
          per_page: 10,
          # the remaining comes from cache
        },
        articles: [
          %Prequest.Manage.Article{ ... },
          %Prequest.Manage.Article{ ... },
          ...
        ],
        query: # Ecto.Query<from a0 in Prequest.Manage.Article, as: :articles,
               # left_join: v1 in assoc(a0, :views), where: ilike(a0.title, ^"%prequest%"),
               # group_by: [a0.id], order_by: [desc: count(v1.id), desc: a0.updated_at],
               # limit: ^2, offset: ^0, select: a0>,
        reports: [
          # from build stage cache.
        ],
        topics: [
          # from build stage cache.
        ]
      }

  """
  @spec page(feed, integer, :nocache, keyword) :: feed
  def page(feed, page, :nocache, [{order, key}] \\ [desc: :date]) do
    feed
    |> Load.view(page: page, sort_by: [{order, key}])
    |> Load.load()
  end
end
