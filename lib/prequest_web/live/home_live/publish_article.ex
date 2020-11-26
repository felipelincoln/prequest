defmodule PrequestWeb.HomeLive.PublishArticle do
  @moduledoc false

  defstruct error: [], url: nil, body: nil, article: nil

  alias Prequest.Manage
  alias Prequest.Manage.Article
  alias PrequestWeb.HomeLive.PublishArticle

  def build(url) do
    %PublishArticle{}
    |> cast_url(url)
    |> put_body()
    |> put_article()
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

  defp put_article(%PublishArticle{error: [], url: url, body: body} = build) do
    title_regex = ~r/\n#\s(.+?[^\\])\n/
    subtitle_regex = ~r/\n(\w.+?[^\\])\n/
    cover_regex = ~r/\!\[.*?\]\((.*?)\)/
    username_regex = ~r/github\.com\/(\w+)\//

    user =
      username_regex
      |> Regex.run(url)
      |> get_or_create_user()

    [_, title] = Regex.run(title_regex, "\n" <> body)
    [_, subtitle] = Regex.run(subtitle_regex, "\n" <> body)
    [_, cover] = Regex.run(cover_regex, "\n" <> body)

    Manage.create_article(%{
      user_id: user.id,
      title: title,
      subtitle: subtitle,
      cover: cover,
      source: url
    })

    build
  end

  defp put_article(build), do: build

  defp get_or_create_user([_, username]) do
    case Manage.get_user(username) do
      nil ->
        {:ok, user} = Manage.create_user(%{username: username})
        user

      user ->
        user
    end
  end
end
