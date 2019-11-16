defmodule AuthN.SessionStorage do
  @type conn :: %Plug.Conn{}
  @callback get_user_id(conn) :: term
  @callback put_user_id(conn, user :: term) :: conn
  @callback delete_user_id(conn) :: conn

  defp session_storage(conn),
    do: Map.get(conn.private, :session_storage, AuthN.SessionStorage.StatelessCookie)

  def get_user_id(conn),
    do: session_storage(conn).get_user_id(conn)

  def put_user_id(conn, user_id),
    do: session_storage(conn).put_user_id(conn, user_id)

  def delete_user_id(conn),
    do: session_storage(conn).delete_user_id(conn)
end
