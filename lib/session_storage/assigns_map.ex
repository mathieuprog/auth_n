defmodule AuthN.SessionStorage.AssignsMap do
  @moduledoc ~S"""
  Module for storing sessions into `conn.private`. Used for testing.
  """

  @behaviour AuthN.SessionStorage

  @type conn :: %Plug.Conn{}

  @spec get_user_id(conn) :: term | nil
  def get_user_id(conn) do
    case conn.private do
      %{auth_current_user_id: current_user_id} -> current_user_id
      _ -> nil
    end
  end

  @spec put_user_id(conn, term) :: conn
  def put_user_id(conn, user_id), do: Plug.Conn.put_private(conn, :auth_current_user_id, user_id)

  @spec delete_user_id(conn) :: conn
  def delete_user_id(conn), do: %{conn | private: Map.delete(conn.private, :auth_current_user_id)}
end
