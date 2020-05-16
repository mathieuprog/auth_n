defmodule AuthN.Accounts do
  use AuthN.Ecto.Accounts,
      ecto_repo: AuthN.Repo,
      user_schema: AuthN.Accounts.User,
      user_notifier: AuthN.UserNotifier
end
