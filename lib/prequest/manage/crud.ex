defmodule Prequest.Manage.CRUD do
  @moduledoc false

  alias Prequest.Manage.CRUD
  alias Prequest.Repo

  @type changeset :: %Ecto.Changeset{}

  @callback create(map) :: {:ok, struct} | {:error, changeset}
  @callback read!(integer) :: struct
  @callback read(term) :: struct | nil
  @callback update(struct, map) :: {:ok, struct} | {:error, changeset}
  @callback delete(struct) :: {:ok, struct} | {:error, changeset}

  @optional_callbacks read: 1

  defmacro __using__([schema: schema] = _opts) do
    quote do
      @behaviour CRUD

      def create(attrs) do
        %unquote(schema){}
        |> unquote(schema).changeset(attrs)
        |> Repo.insert()
      end

      def read!(id) do
        Repo.get!(unquote(schema), id)
      end

      def update(%unquote(schema){} = data, attrs) do
        data
        |> unquote(schema).changeset(attrs)
        |> Repo.update()
      end

      def delete(%unquote(schema){} = data) do
        Repo.delete(data)
      end

      defoverridable CRUD
    end
  end
end
