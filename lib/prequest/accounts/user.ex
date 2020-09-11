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

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :name, :bio])
    |> validate_required([:username])
  end
end
