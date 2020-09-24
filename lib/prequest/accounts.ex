defmodule Prequest.Accounts do
  @moduledoc """
  A interface that underlies database communication for user management.

  # Use cases
  We can do all sort of things related to user management in this context.  
  Let's start by inserting a new user to the database

      iex>Accounts.create_user(%{username: "felipelincoln"})
      {:ok,
       %Prequest.Accounts.User{
         __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
         articles: #Ecto.Association.NotLoaded<association :articles is not loaded>,
         bio: nil,
         id: 1,
         inserted_at: ~N[2020-09-24 09:12:29],
         name: nil,
         reports: #Ecto.Association.NotLoaded<association :reports is not loaded>,
         updated_at: ~N[2020-09-24 09:12:29],
         username: "felipelincoln",
         views: #Ecto.Association.NotLoaded<association :views is not loaded>
       }}

  we can now retrieve this user either by its `id` or `username`

      iex> user = Accounts.get_user! 1
      %Prequest.Accounts.User{
        __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
        articles: #Ecto.Association.NotLoaded<association :articles is not loaded>,
        bio: nil,
        id: 1,
        inserted_at: ~N[2020-09-22 10:45:16],
        name: nil,
        reports: #Ecto.Association.NotLoaded<association :reports is not loaded>,
        updated_at: ~N[2020-09-22 10:45:16],
        username: "felipelincoln",
        views: #Ecto.Association.NotLoaded<association :views is not loaded>
      }
      iex> Accounts.get_user "felipelincoln"
      %Prequest.Accounts.User{
        __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
        articles: #Ecto.Association.NotLoaded<association :articles is not loaded>,
        bio: nil,
        id: 1,
        inserted_at: ~N[2020-09-22 10:45:16],
        name: nil,
        reports: #Ecto.Association.NotLoaded<association :reports is not loaded>,
        updated_at: ~N[2020-09-22 10:45:16],
        username: "felipelincoln",
        views: #Ecto.Association.NotLoaded<association :views is not loaded>
      }

  with `user` we got from database we can update it

      iex> {:ok, user} = Accounts.update_user user, %{bio: "this is my bio"}
      {:ok,
       %Prequest.Accounts.User{
         __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
         articles: #Ecto.Association.NotLoaded<association :articles is not loaded>,
         bio: "this is my bio",
         id: 1,
         inserted_at: ~N[2020-09-22 10:45:16],
         name: nil,
         reports: #Ecto.Association.NotLoaded<association :reports is not loaded>,
         updated_at: ~N[2020-09-24 09:16:59],
         username: "felipelincoln",
         views: #Ecto.Association.NotLoaded<association :views is not loaded>
       }}

  and finally, delete it.

      iex> Accounts.delete_user user
      {:ok,
       %Prequest.Accounts.User{
         __meta__: #Ecto.Schema.Metadata<:deleted, "users">,
         articles: #Ecto.Association.NotLoaded<association :articles is not loaded>,
         bio: nil,
         id: 1,
         inserted_at: ~N[2020-09-22 10:45:16],
         name: nil,
         reports: #Ecto.Association.NotLoaded<association :reports is not loaded>,
         updated_at: ~N[2020-09-22 10:45:16],
         username: "felipelincoln",
         views: #Ecto.Association.NotLoaded<association :views is not loaded>
       }} 

  """

  import Ecto.Query, warn: false
  alias Prequest.Accounts.User
  alias Prequest.Repo

  @type user :: %User{}
  @type changeset :: %Ecto.Changeset{}

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(integer) :: user
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by its username.

  ## Examples

      iex> get_user("felipelincoln")
      %User{}

      iex> get_user("nonexistinguser")
      nil

  """
  @spec get_user(String.t()) :: user
  def get_user(username), do: Repo.get_by(User, username: username)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{
        username: "felipelincoln",
        name: "Felipe de Souza Lincoln",
        bio: "this is my bio"
      })
      {:ok, %User{}}

      iex> create_user(%{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map) :: {:ok, user} | {:error, changeset}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{bio: "updated bio"})
      {:ok, %User{}}

      iex> update_user(user, %{username: nil})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(user, map) :: {:ok, user} | {:error, changeset}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_user(user) :: {:ok, user} | {:error, changeset}
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
