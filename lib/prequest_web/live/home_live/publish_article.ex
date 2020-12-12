defmodule PrequestWeb.HomeLive.PublishArticle do
  @moduledoc false

  defstruct error: [], url: nil, body: nil

  alias Prequest.Manage
  alias Prequest.Manage.Article

  @title_regex %{
    suggested: ~r/\n#\s([^\n]+?)\n/,
    guess_from: %{
      html: ~r/<h\d[^>]*>([^<]*)<\/h\d>/,
      md: ~r/#\s([^\n]+?)\n/
    }
  }
  @cover_regex %{
    suggested: ~r/\!\[cover\]\((https?:\/\/[^\s\n\(\)]+).*\)/,
    guess_from: %{
      html: ~r/<img.*?src="(.+?)".*?>/,
      md:
        ~r/\!\[[^\(\)]*?\]\((https?:\/\/(?!github\.com\.+?badge\.svg|img\.shields|coveralls|codecov)[^\s\n\(\)]+).*\)/
    }
  }
  @subtitle_regex ~r/\n([\w\d][^\n]+?)[\n|\n]/
  @username_regex ~r/github\.com\/(\w+)\//
  @topics_regex ~r/#([^\s\n]+)/

  def cast_url(%__MODULE__{error: []} = build, url) do
    {error, _meta} =
      %Article{}
      |> Article.changeset(%{source: url})
      |> Map.get(:errors)
      |> Keyword.get(:source, {nil, []})

    case error do
      nil -> %{build | url: url}
      error -> %{build | url: url, error: [validation: error]}
    end
  end

  def cast_url(build, _url), do: build

  def put_body(%__MODULE__{error: [], url: url} = build) do
    response =
      url
      |> String.replace("/blob", "", global: false)
      |> String.replace("github.com", "raw.githubusercontent.com")
      |> HTTPoison.get()

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{build | body: "\n" <> body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        %{build | error: [validation: "not found"]}

      _ ->
        %{build | error: [validation: "invalid request"]}
    end
  end

  def put_body(build), do: build

  def create_article(%__MODULE__{error: [], url: url, body: body} = build) do
    user = get_or_create_user(url)
    title = extract_info(@title_regex, body)
    subtitle = extract_info(@subtitle_regex, body)
    cover = extract_info(@cover_regex, body)

    topics =
      @topics_regex
      |> Regex.scan(title <> "\n" <> subtitle)
      |> Enum.map(fn [_match, group] -> %{name: String.downcase(group)} end)

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

        # if article already exist, it updates
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
          [{_field, {msg, _opts}} | _] = changeset.errors
          [validation: msg]
      end

    %{build | error: error}
  end

  def create_article(build), do: build

  defp extract_info(%{suggested: _, guess_from: _} = regex_map, text) do
    extract_info(regex_map.suggested, text) ||
      extract_info(regex_map.guess_from.html, text) ||
      extract_info(regex_map.guess_from.md, text) || ""
  end

  defp extract_info(regex, text) do
    with [_match, group] <- Regex.run(regex, text) do
      group
      |> String.replace("  ", "")
      |> String.replace("\r", "")
      |> String.trim()
    end
  end

  defp get_or_create_user(url) do
    [_match, username] = Regex.run(@username_regex, url)

    case Manage.get_user(username) do
      nil ->
        {:ok, user} = Manage.create_user(%{username: username})
        user

      user ->
        user
    end
  end
end
