defmodule AuthN.HTML.AuthNHelpers do
  def authenticated?(conn) do
    !!AuthN.SessionStorage.get_user_id(conn)
  end

  def current_user(conn) do
    with true <- authenticated?(conn),
         %{current_user: current_user} = conn.assigns do
      current_user
    else
      _ -> nil
    end
  end
end
