defmodule AuthN.HTML.AuthNHelpersTest do
  use ExUnit.Case, async: true

  use Plug.Test

  alias AuthN.SessionStorage
  alias AuthN.SessionStorage.AssignsMap
  alias AuthN.Plugs.SetSessionStorage
  alias AuthN.Plugs.AssignCurrentUser
  alias AuthN.HTML.AuthNHelpers

  test "test view helpers" do
    conn =
      conn(:get, "/")
      |> SetSessionStorage.call(session_storage: AssignsMap)

    assert false == AuthNHelpers.authenticated?(conn)
    assert nil == AuthNHelpers.current_user(conn)

    conn =
      conn
      |> SessionStorage.put_user_token("the user ID")
      |> AssignCurrentUser.call(get_user_by_session_token_fun: fn _user_token -> %{name: "john"} end)

    assert true == AuthNHelpers.authenticated?(conn)
    assert %{name: "john"} = AuthNHelpers.current_user(conn)

    conn = SessionStorage.delete_user_token(conn)

    assert false == AuthNHelpers.authenticated?(conn)
    assert nil == AuthNHelpers.current_user(conn)
  end
end
