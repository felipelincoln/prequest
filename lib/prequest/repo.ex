defmodule Prequest.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :prequest,
    adapter: Ecto.Adapters.Postgres
end
