defmodule Prequest.Manage.TopicCRUD do
  @moduledoc false

  alias Prequest.Repo
  alias Prequest.Manage.{CRUD, Topic}
  use CRUD, schema: Topic

  def read(name) do
    Repo.get_by(Topic, name: name)
  end
end
