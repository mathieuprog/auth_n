defmodule AuthN.SessionStorage.AssignsMap do
  @behaviour AuthN.SessionStorage

  def get_user_id(conn) do
    case conn.private do
      %{auth_current_user_id: current_user_id} -> current_user_id
      _ -> nil
    end
  end

  def put_user_id(conn, user_id), do: Plug.Conn.put_private(conn, :auth_current_user_id, user_id)
  def delete_user_id(conn), do: %{conn | private: Map.delete(conn.private, :auth_current_user_id)}
end
