defmodule Prequest.Feed.Load.DateHelpers do
  @moduledoc false

  def get_months_ago(n) do
    [
      Date.utc_today()
      |> first_day()
      |> months_ago(n)
      |> to_naive_dt(:sunrise),
      Date.utc_today()
      |> last_day()
      |> months_ago(n)
      |> to_naive_dt(:sunset)
    ]
  end

  defp months_ago(%Date{} = date, n) do
    # years to withdraw
    years = div(n, 12) + ((rem(n, 12) >= date.month and 1) || 0)
    # months to withdraw
    months = rem(n, 12) - ((rem(n, 12) >= date.month and 12) || 0)

    %{date | year: date.year - years, month: date.month - months}
  end

  defp first_day(%Date{} = date) do
    %{date | day: 1}
  end

  defp last_day(%Date{} = date) do
    %{date | day: Date.days_in_month(date)}
  end

  defp to_naive_dt(%Date{year: year, month: month, day: day}, :sunrise) do
    {:ok, date} = NaiveDateTime.new(year, month, day, 0, 0, 0)
    date
  end

  defp to_naive_dt(%Date{year: year, month: month, day: day}, :sunset) do
    {:ok, date} = NaiveDateTime.new(year, month, day, 23, 59, 59)
    date
  end
end
