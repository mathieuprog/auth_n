defmodule AuthN.Plugs.SetSessionStorage do
  def init(opts), do: opts

  def call(conn, opts) do
    Plug.Conn.put_private(
      conn,
      :session_storage,
      Keyword.fetch!(opts, :session_storage)
    )
  end
end
