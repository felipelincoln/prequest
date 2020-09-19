defmodule Prequest.CMS.Topic do
  @moduledoc """
  The schema that models the topic.

      schema "topics" do
        field :name, :string

        timestamps()

        many_to_many :articles, Article, join_through: "articles_topics"
      end

  Topic is a category in which an article can be inserted.

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
  * Required: `name`.  
  * Unique: `name`.

  """
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
