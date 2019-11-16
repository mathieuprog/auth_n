defmodule AuthN.Authenticator.DBAuthenticator do
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
