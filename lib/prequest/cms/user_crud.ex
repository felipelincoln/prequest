defmodule Prequest.CMS.UserCRUD do
  @moduledoc """
  CRUD implementation for users
  """

  alias Prequest.CMS.{CRUD, User}
  use CRUD, schema: User
end
