defmodule PrequestWeb.HomeLive.Core do
  @moduledoc false

  alias PrequestWeb.HomeLive.PublishArticle

  def publish_article(url) do
    case PublishArticle.build(url) do
      %{error: []} ->
        {:info, "Success"}

      %{error: [ok: msg]} ->
        {:info, msg}

      %{error: [{field, msg}]} ->
        {:error, "#{to_string(field)} #{msg}"}
    end
  end
end
