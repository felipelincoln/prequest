defmodule Prequest.Manage.Article do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Prequest.Manage.{Article, Report, Topic, User, View}

  schema "articles" do
    field :cover, :string
    field :source, :string
    field :title, :string
    field :subtitle, :string

    timestamps()

    belongs_to :user, User
    has_many :reports, Report
    has_many :views, View
    many_to_many :topics, Topic, join_through: "articles_topics", on_replace: :delete
  end

  def changeset(%Article{} = article, attrs) do
    article
    |> cast(attrs, [:cover, :title, :subtitle, :source, :user_id])
    |> validate_required([:cover, :title, :subtitle, :source, :user_id])
    |> validate_url_format(:cover)
    |> validate_url_format(:source, host: "github.com")
    |> unique_constraint(:source)
    |> assoc_constraint(:user)
  end

  defp validate_url_format(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _field, url ->
      case get_error_from_url(url, opts) do
        nil -> []
        error -> [{field, {error, [{:validation, :url_format}]}}]
      end
    end)
  end

  defp get_error_from_url(url, host: validation_host) do
    get_error_from_url(url, []) ||
      case URI.parse(url).host do
        ^validation_host -> nil
        _ -> "host must be #{validation_host}"
      end
  end

  defp get_error_from_url(url, []) do
    case URI.parse(url) do
      %URI{scheme: nil} ->
        "is missing a scheme (e.g. https)"

      %URI{scheme: scheme} when scheme not in ["http", "https"] ->
        "scheme is invalid. (use http or https)"

      %URI{host: nil} ->
        "is missing a host (e.g. github.com)"

      _ ->
        nil
    end
  end
end
