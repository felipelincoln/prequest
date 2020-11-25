defmodule PrequestWeb.HomeLive.Core do
  @moduledoc false

  def new_article(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        publish_from_content(body)
        {:info, "Success"}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp publish_from_content(_body) do
    0
  end
end
