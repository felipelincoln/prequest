defmodule Prequest.Manage.Feed do
  @moduledoc false

  defstruct articles: [], topics: [], reports: []

  import Prequest.Manage.Helpers, only: [preload!: 2]

  @docs """
  Receives `opts` keyword list and returns a populated struct.

  `opts` can have the keys:
  * `paginate_by`: the amount of articles to show each page
  * `page`: the page it should return
  * `filter`: a string query filtering articles by title
  * `topics`: a way to filter articles by topics
  * `sort`: can be by most viewed or last created.

  """
  def get(source, opts \\ []) do
    articles =
      source
      |> preload!(:articles)
      |> Map.get(:articles)

    __MODULE__.__struct__(%{articles: articles})
  end
end
