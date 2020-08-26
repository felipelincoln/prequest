defmodule Prequest.Repo do
  use Ecto.Repo,
    otp_app: :prequest,
    adapter: Ecto.Adapters.Postgres
end
