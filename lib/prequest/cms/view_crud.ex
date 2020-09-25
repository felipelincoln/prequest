defmodule Prequest.CMS.ViewCRUD do
  @moduledoc """
  CRUD implementation for views
  """

  alias Prequest.Repo
  alias Prequest.CMS.{CRUD, View}
  use CRUD, schema: View

  def get_view(user_id, article_id) do
    Repo.get_by(View, user_id: user_id, article_id: article_id)
  end
end
