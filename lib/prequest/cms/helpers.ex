defmodule Prequest.CMS.Helpers do
  @moduledoc """
  Helpers for CMS
  """

  alias Prequest.Repo

  def preload!(content, fields) do
    Repo.preload(content, fields)
  end

  def preload({:ok, content}) do
    assoc = content.__struct__.__schema__(:associations)
    {:ok, preload!(content, assoc)}
  end

  def preload({:error, changeset}), do: {:error, changeset}
end
