defmodule AuthN.Repo do
  use Ecto.Repo,
    otp_app: :auth_n,
    adapter: Ecto.Adapters.Postgres
end
