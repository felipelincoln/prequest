defmodule Prequest.CMS.View do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.CMS.{Article, User, View}

  schema "views" do
    field :liked?, :boolean, default: false

    timestamps()

    belongs_to :user, User
    belongs_to :article, Article
  end

  def changeset(%View{} = view, attrs) do
    view
    |> cast(attrs, [:liked?, :user_id, :article_id])
    |> validate_required([:article_id, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:article)
    |> unique_constraint([:user, :article], name: :user_article_view_constraint)
  end
end
