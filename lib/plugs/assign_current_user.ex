defmodule AuthN.Plugs.AssignCurrentUser do
  @moduledoc ~S"""
  This plug fetches the current user by the user ID stored in session and stores
  the fetched user in `conn.assigns`.

  The user is fetched by a function provided through the mandatory `:fetch_user`
  option; the function receives the user ID as argument.

  In case no user ID is stored in session, this plug does nothing (just returns
  the `conn` received). In case a user ID is stored in session, but no user can
  be found for that ID, the plug clears the session.
  """

  def init(opts) do
    Keyword.fetch!(opts, :fetch_user)
    opts
  end

  def call(conn, opts) do
    fetch_user_fn = Keyword.fetch!(opts, :fetch_user)

    user_id = AuthN.SessionStorage.get_user_id(conn)

    if user_id do
      assign_user(conn, fetch_user_fn.(user_id))
    else
      conn
    end
  end

  defp assign_user(conn, nil) do
    AuthN.SessionStorage.delete_user_id(conn)
  end

  defp assign_user(conn, user) do
    Plug.Conn.assign(conn, :current_user, user)
  end
end
