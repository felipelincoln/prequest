defmodule Prequest.Manage.UserCRUD do
  @moduledoc false

  alias Prequest.Repo
  alias Prequest.Manage.{CRUD, User}
  use CRUD, schema: User

  def read(username), do: Repo.get_by(User, username: username)
end
