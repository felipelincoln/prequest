defmodule Prequest.CMS.CRUD do
  @moduledoc """
  CRUD implementation
  """

  alias Prequest.CMS.CRUD
  alias Prequest.Repo

  @type changeset :: %Ecto.Changeset{}

  @callback create(map) :: {:ok, struct} | {:error, changeset}
  @callback read!(integer) :: struct
  @callback update(struct, map) :: {:ok, struct} | {:error, changeset}
  @callback delete(struct) :: {:ok, struct} | {:error, changeset}

  defmacro __using__([schema: schema] = _opts) do
    quote do
      @behaviour CRUD

      def create(attrs) do
        unquote(schema).__struct__()
        |> unquote(schema).changeset(attrs)
        |> Repo.insert()
      end

      def read!(id) do
        Repo.get!(unquote(schema), id)
      end

      def update(data, attrs) do
        data
        |> unquote(schema).changeset(attrs)
        |> Repo.update()
      end

      def delete(data) do
        Repo.delete(data)
      end

      defoverridable CRUD
    end
  end
end
