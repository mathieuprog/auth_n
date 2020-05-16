defmodule AuthN.Plugs.AssignCurrentUser do
  @moduledoc ~S"""
  This plug fetches the current user by the user token stored in session and stores
  the user in `conn.assigns`.

  The user is fetched by a function provided through the mandatory `:get_user_by_session_token_fun`
  option; the function receives the user ID as argument.

  In case no user token is stored in session, this plug does nothing (just returns
  the `conn` received). In case a user token is stored in session, but no user can
  be found for that token, the plug clears the session.
  """

  def init(opts) do
    Keyword.fetch!(opts, :get_user_by_session_token_fun)
    opts
  end

  def call(conn, opts) do
    get_user_by_session_token_fun = Keyword.fetch!(opts, :get_user_by_session_token_fun)

    {user_token, conn} = AuthN.SessionStorage.get_user_token(conn)

    if user_token do
      assign_user(conn, get_user_by_session_token_fun.(user_token))
    else
      conn
    end
  end

  defp assign_user(conn, nil) do
    AuthN.SessionStorage.delete_user_token(conn)
  end

  defp assign_user(conn, user) do
    Plug.Conn.assign(conn, :current_user, user)
  end
end
