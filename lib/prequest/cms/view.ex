defmodule Prequest.CMS.View do
  use Ecto.Schema
  import Ecto.Changeset

  schema "view" do
    field :liked, :boolean, default: false
    field :user_id, :id
    field :article_id, :id

    timestamps()
  end

  @doc false
  def changeset(view, attrs) do
    view
    |> cast(attrs, [:liked])
    |> validate_required([:liked])
  end
end
