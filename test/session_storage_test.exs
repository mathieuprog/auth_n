defmodule AuthN.SessionStorageTest do
  use ExUnit.Case, async: true

  use Plug.Test

  alias AuthN.SessionStorage
  alias AuthN.SessionStorage.AssignsMap
  alias AuthN.Plugs.SetSessionStorage

  test "store and retrieve session" do
    conn =
      conn(:get, "/")
      |> SetSessionStorage.call(session_storage: AssignsMap)
      |> SessionStorage.put_user_token("the user ID")

    assert {"the user ID", conn} == SessionStorage.get_user_token(conn)

    conn = SessionStorage.delete_user_token(conn)

    assert {nil, conn} == SessionStorage.get_user_token(conn)
  end
end
