defmodule Prequest.Manage.Helpers do
  @moduledoc """
  A helper module to work with data preloading.
  """

  alias Prequest.Repo

  @type changeset :: %Ecto.Changeset{}

  @doc """
  Preload the articles from a source (user or topic).

  Raises `ArgumentError` if the source does not have `:articles` association, or if the articles'
  struct does not have `:topics`, `:reports` and `:views` associations

  ## Examples

      iex> user
      %User{} #=> articles: #Ecto.Association.NotLoaded<association :articles is not loaded>
      iex> preload_source!(user)
      %User{
        articles: [
          %Article{
            reports: [...],
            topics: [...],
            views: [...],
            ...
          },
          ...
        ],
        ...
      }

      iex> preload_source!(article)
      ** (ArgumentError)
  """
  @spec preload_source!(struct) :: struct
  def preload_source!(source), do: preload!(source, articles: [:topics, :reports, :views])

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
end
