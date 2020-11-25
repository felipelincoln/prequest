defmodule PrequestWeb.HomeLive.PublishArticle do
  @moduledoc false

  defstruct error: [], url: nil, body: nil, article: nil

  alias Prequest.Manage.Article
  alias PrequestWeb.HomeLive.PublishArticle

  def build(%PublishArticle{} = publish_article, url) do
    publish_article
    |> cast_url(url)
    |> put_body()
  end

  defp cast_url(%PublishArticle{error: []} = build, url) do
    {error, _meta} =
      %Article{}
      |> Article.changeset(%{source: url})
      |> Map.get(:errors)
      |> Keyword.get(:source, {nil, []})

    case error do
      nil -> %{build | url: url}
      error -> %{build | url: url, error: [source: error]}
    end
  end

  defp cast_url(build, _url), do: build

  defp put_body(%PublishArticle{error: [], url: url} = build) do
    response =
      url
      |> String.replace("/blob", "")
      |> String.replace("github.com", "raw.githubusercontent.com")
      |> HTTPoison.get()

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{build | body: body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{build | error: [url: "not found"]}

      _ ->
        %{build | error: [url: "invalid request"]}
    end
  end

  defp put_body(build), do: build
end
