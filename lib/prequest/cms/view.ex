defmodule Prequest.CMS.View do
  @moduledoc """
  `View` is the schema in the `CMS` context that model the views.  

      schema "view" do
        field :liked?, :boolean, default: false

        timestamps()

        belongs_to :user, User
        belongs_to :article, Article
      end
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Accounts.User
  alias Prequest.CMS.Article

  schema "view" do
    field :liked?, :boolean, default: false

    timestamps()

    belongs_to :user, User
    belongs_to :article, Article
  end

  @doc """
  # Validation
  Required: `article_id`, `user_id`

  # Examples
  # New view:
      iex> new_view = %{
      ...>   liked: true,
      ...>   article_id: 1
      ...>   user_id: 1
      ...> }
      iex> changeset = View.changeset(%View{}, new_view)
      iex> Repo.insert(changeset)
      {:ok, %View{}}
  """
  def changeset(view, attrs) do
    view
    |> cast(attrs, [:liked?, :user_id, :article_id])
    |> validate_required([:article_id, :user_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:article)
  end
end
