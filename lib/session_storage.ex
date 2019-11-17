defmodule AuthN.SessionStorage do
  @moduledoc ~S"""
  Module used for storing, retrieving and deleting the user ID into/from the session.

  This module serves as an interface, delegating calls to another module implementing
  the session's storage logic. The default implementation module is
  `AuthN.SessionStorage.StatelessCookie`, which stores sessions into stateless cookies.
  Another module implementing sessions storage can be specified by adding the module
  name into the `:session_storage` key of `conn.private`.
  """

  @type conn :: %Plug.Conn{}
  @callback get_user_id(conn) :: term
  @callback put_user_id(conn, user :: term) :: conn
  @callback delete_user_id(conn) :: conn

  @spec session_storage(conn) :: atom
  defp session_storage(conn),
    do: Map.get(conn.private, :session_storage, AuthN.SessionStorage.StatelessCookie)

  @spec get_user_id(conn) :: term | nil
  def get_user_id(conn),
    do: session_storage(conn).get_user_id(conn)

  @spec put_user_id(conn, term) :: conn
  def put_user_id(conn, user_id),
    do: session_storage(conn).put_user_id(conn, user_id)

  @spec delete_user_id(conn) :: conn
  def delete_user_id(conn),
    do: session_storage(conn).delete_user_id(conn)
end
