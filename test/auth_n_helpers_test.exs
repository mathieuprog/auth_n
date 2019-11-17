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
      |> SessionStorage.put_user_id("the user ID")
      |> AssignCurrentUser.call(fetch_user: fn _user_id -> %{name: "john"} end)

    assert true == AuthNHelpers.authenticated?(conn)
    assert %{name: "john"} = AuthNHelpers.current_user(conn)

    conn = SessionStorage.delete_user_id(conn)

    assert false == AuthNHelpers.authenticated?(conn)
    assert nil == AuthNHelpers.current_user(conn)
  end
end
