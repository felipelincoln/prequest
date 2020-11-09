defmodule Prequest.Feed.Load.DateHelpers do
  @moduledoc false

  # defines the date the scroll should stop
  def last_date do
    {:ok, date} = NaiveDateTime.new(2020, 5, 1, 0, 0, 0)
    date
  end

  def get_months_ago(n) do
    [
      Date.utc_today()
      |> months_ago(n)
      |> first_day()
      |> to_naive_dt(:sunrise),
      Date.utc_today()
      |> months_ago(n)
      |> last_day()
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

  defp to_naive_dt(%Date{year: year, month: month, day: day}, sun) do
    time =
      case sun do
        :sunrise -> [0, 0, 0]
        :sunset -> [23, 59, 59]
      end

    {:ok, naive_dt} = apply(&NaiveDateTime.new/6, [year, month, day] ++ time)

    naive_dt
  end
end
