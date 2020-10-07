defmodule Prequest.Feed do
  @moduledoc """
  A public API for Feed fetching.
  """

  defstruct __meta__: %{}, query: nil, articles: [], reports: [], topics: []
end
