defmodule PrequestWeb.ArticleLive.Core do
  @moduledoc false

  alias Prequest.{Helpers, Manage}

  def get_content(%{"username" => username, "article_id" => article_id}) do
    article_id
    |> Manage.get_article!()
    |> validate_user!(username)
    |> request!()
  rescue
    _error -> "404 not found!"
  end

  defp validate_user!(article, username) do
    ^username =
      article
      |> Helpers.preload!(:user)
      |> Map.get(:user)
      |> Map.get(:username)

    article
  end

  defp request!(%{source: source}) do
    {:ok, %{body: body}} =
      source
      |> String.replace("/blob", "", global: false)
      |> String.replace("github.com", "raw.githubusercontent.com")
      |> HTTPoison.get()

    body
  end
end
