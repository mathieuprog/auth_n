defmodule AuthN.HTML.AuthNHelpers do
  @doc ~S"""
  View helper allowing to check whether the current user is authenticated or not.
  """
  @spec authenticated?(Plug.Conn.t()) :: boolean
  def authenticated?(conn) do
    {user_token, _conn} = AuthN.SessionStorage.get_user_token(conn)
    !!user_token
  end

  @doc ~S"""
  View helper returning the current user or `nil` in case the current user is not
  authenticated.
  """
  @spec current_user(Plug.Conn.t()) :: term | nil
  def current_user(conn) do
    with true <- authenticated?(conn),
         %{current_user: current_user} = conn.assigns do
      current_user
    else
      _ -> nil
    end
  end
end
