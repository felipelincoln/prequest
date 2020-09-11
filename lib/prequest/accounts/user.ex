defmodule Prequest.Accounts.User do
  @moduledoc """
  `User` is the schema in the `Accounts` context that model the users.  

  It consists of a `:bio`, `:name` and `:username` field plus the `timestamps()`.
  ```elixir
  schema "users" do
    field :bio, :string
    field :name, :string
    field :username, :string

    timestamps()
  end
  ```
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :bio, :string
    field :name, :string
    field :username, :string

    timestamps()
  end

  @doc """
  Returns an `Ecto.Changeset` for the `%Prequest.Accounts.User{}` struct, given the attrs `%{...}`

  ## Examples

      iex> changeset(%User{}, %{username: "felipelincoln"})
      #Ecto.Changeset<
        action: nil,
        changes: %{username: "felipelincoln"},
        errors: [],
        data: #Prequest.Accounts.User<>,
        valid?: true
      >
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :name, :bio])
    |> validate_required([:username])
  end
end
