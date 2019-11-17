defmodule AuthN.Plugs.SetSessionStorage do
  @moduledoc ~S"""
  This plug allows to change the storage mechanism for sessions.

  By default, the session is stored into a stateless cookie.
  """

  def init(opts), do: opts

  def call(conn, opts) do
    Plug.Conn.put_private(
      conn,
      :session_storage,
      Keyword.fetch!(opts, :session_storage)
    )
  end
end
