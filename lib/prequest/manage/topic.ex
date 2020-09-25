defmodule Prequest.Manage.Topic do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Manage.{Article, Topic}

  schema "topics" do
    field :name, :string

    timestamps()

    many_to_many :articles, Article, join_through: "articles_topics"
  end

  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
