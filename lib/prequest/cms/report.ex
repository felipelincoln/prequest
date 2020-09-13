defmodule Prequest.CMS.Report do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reports" do
    field :message, :string
    field :user_id, :id
    field :article_id, :id

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:message])
    |> validate_required([:message])
  end
end
