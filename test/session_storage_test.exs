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
      |> SessionStorage.put_user_id("the user ID")

    assert "the user ID" == SessionStorage.get_user_id(conn)

    conn = SessionStorage.delete_user_id(conn)

    assert nil == SessionStorage.get_user_id(conn)
  end
end
