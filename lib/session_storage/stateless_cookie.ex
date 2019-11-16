defmodule AuthN.SessionStorage.StatelessCookie do
  @behaviour AuthN.SessionStorage

  import Plug.Conn

  def get_user_id(conn), do: get_session(conn, :current_user_id)

  def put_user_id(conn, user_id) do
    put_session(conn, :current_user_id, user_id)
    |> configure_session(renew: true)
  end

  def delete_user_id(conn) do
    delete_session(conn, :current_user_id)
    |> configure_session(drop: true)
  end
end
