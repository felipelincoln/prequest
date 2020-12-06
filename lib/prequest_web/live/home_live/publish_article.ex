defmodule PrequestWeb.HomeLive.PublishArticle do
  @moduledoc false

  defstruct error: [], url: nil, body: nil

  alias Prequest.Manage
  alias Prequest.Manage.Article
  alias PrequestWeb.HomeLive.PublishArticle

  def build(url) do
    %PublishArticle{}
    |> cast_url(url)
    |> put_body()
    |> create_article()
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

  defp create_article(%PublishArticle{error: [], url: url, body: body} = build) do
    title_regex = ~r/\n#\s([^\n\r]+?)\n/
    subtitle_regex = ~r/\n([\w\d][^\n\r]+?)\n/
    cover_regex = ~r/\!\[.*?\]\((.*?)\)/
    username_regex = ~r/github\.com\/(\w+)\//

    user =
      username_regex
      |> Regex.run(url)
      |> get_or_create_user()

    title = extract_info(title_regex, "\n" <> body)
    subtitle = extract_info(subtitle_regex, body)
    cover = extract_info(cover_regex, body)

    topics_regex = ~r/#([^\s\n\r]+)/

    topics =
      extract_all(topics_regex, title <> "\n" <> subtitle)
      |> Enum.map(fn topic -> %{name: topic} end)

    params = %{
      user_id: user.id,
      title: title,
      subtitle: subtitle,
      cover: cover,
      source: url,
      topics: topics
    }

    error =
      case Manage.create_article(params) do
        {:ok, _article} ->
          []

        # if article already exist, it refreshes
        {:error, %{errors: [source: _msg]}} ->
          url
          |> Manage.get_article_by_source()
          |> Manage.update_article(%{
            title: title,
            subtitle: subtitle,
            cover: cover,
            topics: topics
          })

          [ok: "article updated"]

        {:error, changeset} ->
          [{field, {msg, _opts}} | _] = changeset.errors
          [{field, msg}]
      end

    %{build | error: error}
  end

  defp create_article(build), do: build

  defp extract_all(regex, text) do
    Regex.scan(regex, text)
    |> Enum.map(fn [_match, group] -> String.downcase(group) end)
  end

  defp extract_info(regex, text) do
    case Regex.run(regex, text) do
      nil -> ""
      [_match, group] -> clean_string(group)
    end
  end

  defp clean_string(str) do
    str
    |> String.replace("  ", "")
    |> String.trim()
  end

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
