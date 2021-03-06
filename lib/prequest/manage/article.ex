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
    |> validate_required(:title, message: "this article has no title")
    |> validate_required(:subtitle, message: "this article has no subtitle")
    |> validate_required(:source, message: "insert a url from a markdown file on GitHub")
    |> validate_required(:user_id)
    |> validate_length(:title, min: 2, message: "the title of this article is too short. min: 2")
    |> validate_url_format(:cover)
    |> validate_url_format(:source, host: "github.com")
    |> validate_url_extension(:source, ".md")
    |> discard_invalid(:cover)
    |> unique_constraint(:source)
    |> assoc_constraint(:user)
  end

  defp discard_invalid(changeset, field) do
    if field in Keyword.keys(changeset.errors) do
      attrs =
        changeset
        |> delete_change(field)
        |> Map.get(:changes)

      changeset(%Article{}, attrs)
    else
      changeset
    end
  end

  defp validate_url_extension(changeset, field, value) do
    validate_change(changeset, field, fn _field, url ->
      case String.ends_with?(url, value) do
        true ->
          []

        false ->
          error = "must be #{value} extension"
          [{field, {error, [{:validation, :url_extension}]}}]
      end
    end)
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
