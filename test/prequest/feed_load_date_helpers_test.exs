defmodule Prequest.FeedLoadDateHelpersTest do
  use Prequest.DataCase, async: true

  alias Prequest.Feed.Load.DateHelpers

  test "last_date/0 returns the naive date 2020/05/01 00:00:00" do
    {:ok, date} = NaiveDateTime.new(2020, 5, 1, 0, 0, 0)
    assert DateHelpers.last_date() == date
  end

  test "get_months_ago/1 for n = 0 returns 1st and last day of today's month" do
    today = Date.utc_today()
    last_day = Date.days_in_month(today)

    {:ok, first_naive} = NaiveDateTime.new(today.year, today.month, 1, 0, 0, 0)
    {:ok, second_naive} = NaiveDateTime.new(today.year, today.month, last_day, 23, 59, 59)

    assert [first_naive, second_naive] == DateHelpers.get_months_ago(0)
  end

  test "get_months_ago/1 for n = k returns 1st and last day of k-th month" do
    for k <- 1..50 do
      assert [%NaiveDateTime{day: 1}, %NaiveDateTime{day: day}] = DateHelpers.get_months_ago(k)
      assert day in [28, 29, 30, 31]
    end
  end
end
