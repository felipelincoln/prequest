defmodule Prequest.CMS.Topic do
  @moduledoc """
  `Topic` is the schema in the `CMS` context that model the topics.  

      schema "topics" do
        field :name, :string

        timestamps()

        many_to_many :articles, Article, join_through: "articles_topics"
      end
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.CMS.{Article, Topic}

  schema "topics" do
    field :name, :string

    timestamps()

    many_to_many :articles, Article, join_through: "articles_topics"
  end

  @doc """
  Topic's changeset.

  ## Validation
  Required: `name`.  
  Unique: `name`.

  ## Examples
  New topic:
      iex> new_topic = %{name: "elixir"}
      iex> changeset = Topic.changeset(%Topic{}, new_topic)
      iex> Repo.insert(changeset)
      {:ok, %Topic{}}

  """
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
