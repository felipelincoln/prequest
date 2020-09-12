defmodule Prequest.CMS.Article do
  @moduledoc """
  `Article` is the schema in the `CMS` context that model the articles.  

  It consists of a `:title`, `:cover`, `:source` field and `belongs_to :user` plus the `timestamps()`.
      schema "articles" do
        field :cover, :string
        field :source, :string
        field :title, :string

        timestamps()

        belongs_to :user, User
      end
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Accounts.User
  alias Prequest.CMS.Article

  schema "articles" do
    field :cover, :string
    field :source, :string
    field :title, :string

    timestamps()

    belongs_to :user, User
  end

  @doc false
  def changeset(%Article{} = article, attrs) do
    article
    |> cast(attrs, [:title, :source])
    |> cast_assoc(:user)
    |> validate_required([:title, :source])
    |> unique_constraint(:source)
  end
end
