defmodule AuthN.SessionStorage do
  @moduledoc ~S"""
  Module used for storing, retrieving and deleting the user token into/from the session.

  This module serves as an interface, delegating calls to another module implementing
  the session's storage logic. The default implementation module is
  `AuthN.SessionStorage.StatelessCookie`, which stores sessions into stateless cookies.
  Another module implementing sessions storage can be specified by adding the module
  name into the `:session_storage` key of `conn.private`.
  """

  @type conn :: %Plug.Conn{}
  @callback get_user_token(conn) :: {term, conn}
  @callback put_user_token(conn, user :: term) :: conn
  @callback delete_user_token(conn, function) :: conn

  @spec session_storage(conn) :: atom
  defp session_storage(conn),
    do: Map.get(conn.private, :session_storage, AuthN.SessionStorage.StatelessCookie)

  @spec get_user_token(conn) :: term | nil
  def get_user_token(conn),
    do: session_storage(conn).get_user_token(conn)

  @spec put_user_token(conn, term) :: conn
  def put_user_token(conn, user_token),
    do: session_storage(conn).put_user_token(conn, user_token)

  @spec delete_user_token(conn, function) :: conn
  def delete_user_token(conn, delete_session_token_fun \\ &(&1)),
    do: session_storage(conn).delete_user_token(conn, delete_session_token_fun)
end
