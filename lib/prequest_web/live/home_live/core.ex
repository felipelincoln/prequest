defmodule PrequestWeb.HomeLive.Core do
  @moduledoc false

  alias PrequestWeb.HomeLive.PublishArticle

  def publish_article(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:info, "Success"}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
