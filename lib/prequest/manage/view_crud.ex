defmodule Prequest.Manage.ViewCRUD do
  @moduledoc false

  alias Prequest.Repo
  alias Prequest.Manage.{CRUD, View}
  use CRUD, schema: View

  def read({user_id, article_id}) do
    Repo.get_by(View, user_id: user_id, article_id: article_id)
  end
end
