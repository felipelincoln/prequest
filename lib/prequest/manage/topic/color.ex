defmodule Prequest.Manage.Topic.Color do
  @moduledoc """
  A custom color manager.

  To add a new color just add a `from/1'` clause matching the topic name.

      # lib/prequest/manage/topic/color.ex
      # Example of adding a color for the "elixir" tag.
      ...
      def from("elixir"), do: "bg-purple-800" # new clause
      def from(_), do: random()
      ...

  The new custom clause must be declared before `from(_)` clause.

  Color reference: [TailwindCSS](https://tailwindcss.com/docs/background-color)
  """

  @names ["gray", "red", "orange", "yellow", "green", "teal", "blue", "indigo", "purple", "pink"]
  @values [300, 400, 500, 600, 700, 800, 900]

  @doc """
  Generate a random class for background color.

  ## Examples

      iex> Color.random()
      "bg-blue-500"

  """
  @spec random() :: String.t()
  def random do
    "bg-#{Enum.random(@names)}-#{Enum.random(@values)}"
  end

  @doc """
  Get a class for background color for the given topic.

  If the topic name is not declared as a `from/1` clause, it wil generate a random class using `random/0`.

  ## Examples

      iex> Color.from("elixir")
      "bg-purple-800"

      iex> Color.from("a")
      "bg-green-300" # random

  """
  @spec from(String.t()) :: String.t()
  def from("elixir"), do: "bg-purple-800"
  def from("javascript"), do: "bg-yellow-400"
  def from("docker"), do: "bg-blue-500"
  def from("jenkins"), do: "bg-red-700"
  def from("ecto"), do: "bg-green-500"
  def from("others"), do: "bg-gray-400"
  def from(_), do: random()
end
