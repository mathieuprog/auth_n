defmodule AuthN.SessionStorage.AssignsMap do
  @moduledoc ~S"""
  Module for storing sessions into `conn.private`. Used for testing.
  """

  @behaviour AuthN.SessionStorage

  @type conn :: %Plug.Conn{}

  @spec get_user_token(conn) :: {term | nil, conn}
  def get_user_token(conn) do
    user_token =
      case conn.private do
        %{auth_user_token: user_token} -> user_token
        _ -> nil
      end
    {user_token, conn}
  end

  @spec put_user_token(conn, term) :: conn
  def put_user_token(conn, user_token), do: Plug.Conn.put_private(conn, :auth_user_token, user_token)

  @spec delete_user_token(conn, function) :: conn
  def delete_user_token(conn, _), do: %{conn | private: Map.delete(conn.private, :auth_user_token)}
end
