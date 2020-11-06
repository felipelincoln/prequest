defmodule Prequest.Manage.Topic.Color do
  @moduledoc """
  A custom color manager.

  To add a new color just add a `color_class/1'` clause matching the topic name.

      # lib/prequest/manage/topic/color.ex
      # Example of adding a color for the "elixir" tag.
      ...
      def color_class("elixir"), do: "bg-purple-800" # new clause
      def color_class(_), do: random()
      ...

  The new custom clause must be declared before `color_class(_)` clause.

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

  If the topic name is not declared as a `color_class/1` clause, it wil generate a random class using `random/0`.

  ## Examples

      iex> Color.color_class("elixir")
      "bg-purple-800"

      iex> Color.color_class("a")
      "bg-green-300" # random

  """
  @spec color_class(String.t()) :: String.t()
  def color_class("elixir"), do: "bg-purple-800"
  def color_class("javascript"), do: "bg-yellow-400"
  def color_class("docker"), do: "bg-blue-500"
  def color_class("jenkins"), do: "bg-red-700"
  def color_class("ecto"), do: "bg-green-500"
  def color_class("others"), do: "bg-gray-400"
  def color_class(_), do: random()
end
