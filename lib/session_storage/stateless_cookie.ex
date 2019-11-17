defmodule AuthN.SessionStorage.StatelessCookie do
  @moduledoc ~S"""
  Module for storing sessions into stateless cookies.

  This is the library's default storage mechanism for storing sessions.
  """

  @behaviour AuthN.SessionStorage

  import Plug.Conn

  @type conn :: %Plug.Conn{}

  @spec get_user_id(conn) :: term | nil
  def get_user_id(conn), do: get_session(conn, :current_user_id)

  @spec put_user_id(conn, term) :: conn
  def put_user_id(conn, user_id) do
    put_session(conn, :current_user_id, user_id)
    |> configure_session(renew: true)
  end

  @spec delete_user_id(conn) :: conn
  def delete_user_id(conn) do
    delete_session(conn, :current_user_id)
    |> configure_session(drop: true)
  end
end
