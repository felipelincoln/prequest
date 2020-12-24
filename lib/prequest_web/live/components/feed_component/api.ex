defmodule PrequestWeb.Components.FeedComponent.API do
  @moduledoc false

  import Prequest.Feed.Load.DateHelpers, only: [get_months_ago: 1]
  import Phoenix.LiveView.Helpers, only: [sigil_L: 2]
  alias PrequestWeb.Components.FeedComponent.Core

  def highlight_query(_socket, text, ""), do: text

  def highlight_query(socket, text, query) do
    regex = ~r/#{Regex.escape(query)}/i
    [init_part | unmarked_parts] = Regex.split(regex, text)
    marked_parts = Regex.scan(regex, text) |> Enum.map(fn [x] -> x end)
    parts = List.zip([marked_parts, unmarked_parts])

    assigns = %{
      socket: socket,
      init_part: init_part,
      parts: parts
    }

    ~L"<%= @init_part %><%= for {marked, normal} <- parts do %><mark><%= marked %></mark><%= normal %><% end %>"
  end

  def get_issues(reports) do
    count = Enum.count(reports)

    case count do
      1 -> "1 issue"
      _ -> "#{count} issues"
    end
  end

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

  def get_short_month_name(n) do
    n
    |> get_month_name()
    |> String.slice(0, 3)
  end

  def get_month_name(n) do
    [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ]
    |> Enum.at(n - 1)
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
