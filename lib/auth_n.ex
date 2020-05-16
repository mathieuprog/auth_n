defmodule AuthN do
  def valid_password?(user, hashed_password_field, password, opts \\ [])
      when byte_size(password) > 0 do
    hashing_module = Keyword.get(opts, :hashing_module, Argon2)

    case user && Map.get(user, hashed_password_field) do
      nil ->
        hashing_module.no_user_verify()
        false
      hashed_password when is_binary(hashed_password) ->
        hashing_module.verify_pass(password, hashed_password)
    end
  end
end
