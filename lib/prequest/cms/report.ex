defmodule Prequest.CMS.Report do
  @moduledoc """
  The schema that models the report.

      schema "reports" do
        field :message, :string

        timestamps()

        belongs_to :user, Accounts.User
        belongs_to :article, Article
      end

  Report is a type of interaction one can make with an article, whether a registered user or not.
  This should point out problems in the article's content. Once spotted, it is easier for
  other (or even the author) to find it in order to fix it.

  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.CMS.{Article, Report, User}

  schema "reports" do
    field :message, :string

    timestamps()

    belongs_to :user, User
    belongs_to :article, Article
  end

  @doc """
  Report's changeset

  ## Validation
  * Required: `article_id`.

  """
  def changeset(%Report{} = report, attrs) do
    report
    |> cast(attrs, [:message, :user_id, :article_id])
    |> validate_required([:article_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:article)
  end
end
