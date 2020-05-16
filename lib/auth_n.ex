defmodule AuthN do
  def valid_password?(%{} = user, password, opts \\ [])
      when byte_size(password) > 0 do
    field = Keyword.get(opts, :hashed_password_field, :hashed_password)
    hashing_module = Keyword.get(opts, :hashing_module, Argon2)

    case Map.get(user, field) do
      nil ->
        hashing_module.no_user_verify()
        false
      hashed_password when is_binary(hashed_password) ->
        hashing_module.verify_pass(password, hashed_password)
    end
  end
end
