defmodule AuthN.Authenticator.DBAuthenticator do
  @doc ~S"""
  Authenticates a user's credentials against a given repository and schema.

  The given schema must implement the `AuthN.Ecto.AuthNFields` behaviour, which
  allows this function to retrieve the identifier and password schema field names.

  Currently, this function assumes the password is hashed using the `Argon2`
  function. `Argon2` is recommended over `bcrypt`. See `argon2_elixir` package.

  Returns the tuple `{:ok, user}` in case of successful authentication (where user
  is the struct fetched from the data store that aligns with the given credentials),
  `{:error, :unknown_user}` in case the given identifier is not found in the data
  store, and `{:error, :wrong_password}` in case the given password doesn't match the
  one found in the data store.
  """
  @spec authenticate(String.t(), String.t(), {atom, atom}) :: {:ok, struct} | {:error, atom}
  def authenticate(identifier, password, {repo_module_name, schema_module_name}) do
    identifier_field = schema_module_name.get_identifier_field()
    password_field = schema_module_name.get_password_field()

    user = repo_module_name.get_by(schema_module_name, [{identifier_field, identifier}])

    cond do
      user == nil ->
        Argon2.no_user_verify()
        {:error, :unknown_user}

      true ->
        stored_hashed_password = Map.fetch!(user, password_field)

        if Argon2.verify_pass(password, stored_hashed_password) do
          {:ok, user}
        else
          {:error, :wrong_password}
        end
    end
  end
end
