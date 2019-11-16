defmodule AuthN.Plugs.AssignCurrentUser do
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
