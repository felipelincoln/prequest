defmodule Prequest.CMS.Report do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.CMS.{Article, Report, User}

  schema "reports" do
    field :message, :string

    timestamps()

    belongs_to :user, User
    belongs_to :article, Article
  end

  def changeset(%Report{} = report, attrs) do
    report
    |> cast(attrs, [:message, :user_id, :article_id])
    |> validate_required([:article_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:article)
  end
end
