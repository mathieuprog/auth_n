defmodule AuthN.Authenticator.DBAuthenticatorTest do
  use ExUnit.Case, async: true

  use Plug.Test

  alias AuthN.Authenticator.DBAuthenticator

  defmodule User do
    use Ecto.Schema
    use AuthN.Ecto.AuthNFields

    schema "users" do
      identifier_field :username
      password_field :password_hash
    end
  end

  defmodule FakeRepo do
    def get_by(queryable, clauses) do
      username = Keyword.fetch!(clauses, :username)

      if username == "john" do
        struct(queryable,
          username: username,
          password_hash: Argon2.hash_pwd_salt("1234")
        )
      end
    end
  end

  test "successful authentication" do
    assert {:ok, _} = DBAuthenticator.authenticate("john", "1234", {FakeRepo, User})
  end

  test "failed authentication: unknown user" do
    assert {:error, :unknown_user} =
             DBAuthenticator.authenticate("jane", "1234", {FakeRepo, User})
  end

  test "failed authentication: wrong password" do
    assert {:error, :wrong_password} =
             DBAuthenticator.authenticate("john", "4321", {FakeRepo, User})
  end
end
