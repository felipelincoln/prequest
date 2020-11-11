defmodule PrequestWeb.FeedComponent.API do
  @moduledoc false

  import Prequest.Feed.Load.DateHelpers, only: [get_months_ago: 1]
  alias PrequestWeb.FeedComponent.Core

  def get_filter(meta), do: Core.get_filter(meta)

  def last_feed?(range) do
    date = get_date(range)
    NaiveDateTime.compare(last_valid_date(), date) == :gt
  end

  def get_feed_name(0), do: "Recent"
  def get_feed_name(1), do: "Last month"

  def get_feed_name(range) do
    date = get_date(range)
    month = get_month_name(date.month)

    "#{month}, #{date.year}"
  end

  defp get_month_name(n) do
    case n do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
    end
  end

  defp get_date(range) do
    [date, _] = get_months_ago(range)

    date
  end

  defp last_valid_date do
    {:ok, date} = NaiveDateTime.new(2020, 5, 1, 0, 0, 0)

    date
  end
end
