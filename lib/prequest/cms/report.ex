defmodule Prequest.CMS.Report do
  @moduledoc """
  `Report` is the schema in the `CMS` context that model the reports.  

      schema "reports" do
        field :message, :string

        timestamps()

        belongs_to :user, User
        belongs_to :article, Article
      end
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Accounts.User
  alias Prequest.CMS.Article

  schema "reports" do
    field :message, :string

    timestamps()

    belongs_to :user, User
    belongs_to :article, Article
  end

  @doc """
  # Validation
  Required: `article_id`

  # Examples
  # New report:
      iex> new_report = %{
      ...>   title: "I found a typo here",
      ...>   article_id: 1
      ...> }
      iex> changeset = Report.changeset(%Report{}, new_report)
      iex> Repo.insert(changeset)
      {:ok, %Report{}}
  """
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:message, :user_id, :article_id])
    |> validate_required([:article_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:article)
  end
end
