defmodule PrequestWeb.HomeLive.Core do
  @moduledoc false

  alias PrequestWeb.HomeLive.PublishArticle
  import PublishArticle, only: [cast_url: 2, put_body: 1, create_article: 1]

  def publish_article(url) do
    %PublishArticle{}
    |> cast_url(url)
    |> put_body()
    |> create_article()
    |> case do
      %{error: []} ->
        {:info, "Success"}

      %{error: [ok: msg]} ->
        {:info, msg}

      %{error: [validation: msg]} ->
        {:error, msg}
    end
  end
end
