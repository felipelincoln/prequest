defmodule Prequest.CMS.View do
  @moduledoc """
  The schema that models the view.

      schema "view" do
        field :liked?, :boolean, default: false

        timestamps()

        belongs_to :user, Accounts.User
        belongs_to :article, Article
      end

  View is the interaction between a user and an article. It shows when the article
  was viewed and liked by the user.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Accounts
  alias Prequest.CMS.{Article, View}

  schema "view" do
    field :liked?, :boolean, default: false

    timestamps()

    belongs_to :user, Accounts.User
    belongs_to :article, Article
  end

  @doc """
  View's changeset.

  ## Validation
  * Required: `article_id`, `user_id`.

  """
  def changeset(%View{} = view, attrs) do
    view
    |> cast(attrs, [:liked?, :user_id, :article_id])
    |> validate_required([:article_id, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:article)
  end
end
