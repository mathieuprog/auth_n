{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = AuthN.Repo.start_link()

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(AuthN.Repo, :manual)
