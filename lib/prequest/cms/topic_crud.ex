defmodule Prequest.CMS.TopicCRUD do
  @moduledoc """
  CRUD implementation for topics
  """

  alias Prequest.Repo
  alias Prequest.CMS.{CRUD, Topic}
  use CRUD, schema: Topic

  def get_topic(name) do
    Repo.get_by(Topic, name: name)
  end
end
