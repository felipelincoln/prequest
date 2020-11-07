defmodule Prequest.Feed.Load.DateHelpers do
  @moduledoc false

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

  def months_ago(%Date{} = date, n) do
    # years to withdraw
    years = div(n, 12) + ((rem(n, 12) >= date.month and 1) || 0)
    # months to withdraw
    months = rem(n, 12) - ((rem(n, 12) >= date.month and 12) || 0)

    %{date | year: date.year - years, month: date.month - months}
  end

  def first_day(%Date{} = date) do
    %{date | day: 1}
  end

  def last_day(%Date{} = date) do
    %{date | day: Date.days_in_month(date)}
  end

  def to_naive_dt(%Date{year: year, month: month, day: day} = date, sun) do
    time =
      case sun do
        :sunrise -> [0, 0, 0]
        :sunset -> [23, 59, 59]
      end

    case apply(&NaiveDateTime.new/6, [year, month, day] ++ time) do
      {:ok, naive_dt} ->
        naive_dt

      {:error, _reason} ->
        %{date | day: day - 1}
        |> to_naive_dt(sun)
    end
  end
end
