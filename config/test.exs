use Mix.Config

config :logger, level: :warn

config :auth_n,
  ecto_repos: [AuthN.Repo]

config :auth_n, AuthN.Repo,
  username: "postgres",
  password: "postgres",
  database: "auth_n_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support"
