defmodule AuthN.Accounts.User do
  use Ecto.Schema

  @derive {Inspect, except: [:password]}
  schema "users" do
    field(:email, :string)
    field(:hashed_password, :string)
    field(:password, :string, virtual: true)
    field(:confirmed_at, :naive_datetime)
    timestamps()
  end

  use AuthN.Ecto.UserChangesets,
      fields: [email: :email, password: :hashed_password, clear_password: :password, confirmed_at: :confirmed_at],
      hashing_module: Argon2

  use AuthN.Ecto.UserToken,
      ecto_schema: Ecto.Schema,
      user_schema: AuthN.Accounts.User
end
