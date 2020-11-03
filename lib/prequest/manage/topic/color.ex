defmodule Prequest.Manage.Topic.Color do
  @moduledoc """
  Color reference: [TailwindCSS](https://tailwindcss.com/docs/background-color)
  """

  @names ["gray", "red", "orange", "yellow", "green", "teal", "blue", "indigo", "purple", "pink"]
  @values [300, 400, 500, 600, 700, 800, 900]

  @doc """
  Generate a random class for tailwind's background color.

  # Examples

      iex> Color.random()
      "bg-blue-500"

  """
  def random do
    "bg-#{Enum.random(@names)}-#{Enum.random(@values)}"
  end

  @doc """
  Obtain a tailwind's background color class for a topic.

  If the topic name is not declared as a from/1 clause, it wil generate a random class using random/0.

  # Examples

      iex> Color.from("elixir")
      "bg-purple-900"

      iex> Color.from("a")
      "bg-green-300" # random

  """
  def from("elixir"), do: "bg-purple-900"
  def from("others"), do: "bg-gray-400"
  def from(_), do: random()
end
