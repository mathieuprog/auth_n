defmodule AuthN.SessionStorage.StatelessCookie do
  @moduledoc ~S"""
  Module for storing sessions into stateless cookies.

  This is the library's default storage mechanism for storing sessions.
  """

  @remember_me_cookie "user_remember_me"

  @behaviour AuthN.SessionStorage

  import Plug.Conn

  @type conn :: %Plug.Conn{}

  @spec get_user_token(conn) :: {term | nil, conn}
  def get_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @spec put_user_token(conn, term) :: conn
  def put_user_token(conn, user_token, opts \\ []) do
    conn
    |> renew_session()
    |> put_session(:user_token, user_token)
    |> maybe_write_remember_me_cookie(user_token, opts)
  end

  defp maybe_write_remember_me_cookie(conn, token, max_days: max_days) when is_integer(max_days) do
    put_resp_cookie(conn, @remember_me_cookie, token, [sign: true, max_age: max_days * 60 * 24 * 60])
  end

  defp maybe_write_remember_me_cookie(conn, _token, _opts) do
    conn
  end

  @spec delete_user_token(conn, function) :: conn
  def delete_user_token(conn, delete_session_token_fun \\ &(&1)) do
    user_token = get_session(conn, :user_token)
    user_token && delete_session_token_fun.(user_token)

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end
end
