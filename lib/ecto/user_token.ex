defmodule AuthN.Ecto.UserToken do
  defmacro __using__(opts) do
    user_schema = Keyword.fetch!(opts, :user_schema) |> Macro.expand(__ENV__)
    ecto_schema = Keyword.get(opts, :ecto_schema, Ecto.Schema) |> Macro.expand(__ENV__)
    schema_name = Keyword.get(opts, :schema_name, "users_tokens")
    hash_algorithm = Keyword.get(opts, :hash_algorithm, :sha256)
    rand_size = Keyword.get(opts, :rand_size, 32)
    reset_password_validity_in_days = Keyword.get(opts, :reset_password_validity_in_days, 1)
    confirm_validity_in_days = Keyword.get(opts, :confirm_validity_in_days, 7)
    change_email_validity_in_days = Keyword.get(opts, :change_email_validity_in_days, 7)
    session_validity_in_days = Keyword.get(opts, :session_validity_in_days, 60)

    quote do
      defmodule unquote(Module.concat([user_schema, Token])) do
        use unquote(ecto_schema)

        import Ecto.Query

        schema unquote(schema_name) do
          field :token, :binary
          field :context, :string
          field :sent_to, :string
          belongs_to :user, unquote(user_schema)

          timestamps(updated_at: false)
        end

        @doc """
        Generates a token that will be stored in a signed place,
        such as session or cookie. As they are signed, those
        tokens do not need to be hashed.
        """
        def build_session_token(user) do
          token = :crypto.strong_rand_bytes(unquote(rand_size))
          {token, %__MODULE__{token: token, context: "session", user_id: user.id}}
        end

        @doc """
        Checks if the token is valid and returns its underlying lookup query.

        The query returns the user found by the token.
        """
        def verify_session_token_query(token) do
          query =
            from token in token_and_context_query(token, "session"),
                 join: user in assoc(token, :user),
                 where: token.inserted_at > ago(unquote(session_validity_in_days), "day"),
                 select: user

          {:ok, query}
        end

        @doc """
        Builds a token with a hashed counter part.

        The non-hashed token is sent to the user e-mail while the
        hashed part is stored in the database, to avoid reconstruction.
        The token is valid for a week as long as users don't change
        their email.
        """
        def build_user_email_token(user, context) do
          build_hashed_token(user, context, user.email)
        end

        defp build_hashed_token(user, context, sent_to) do
          token = :crypto.strong_rand_bytes(unquote(rand_size))
          hashed_token = :crypto.hash(unquote(hash_algorithm), token)

          {Base.url_encode64(token, padding: false),
            %__MODULE__{
              token: hashed_token,
              context: context,
              sent_to: sent_to,
              user_id: user.id
            }}
        end

        @doc """
        Checks if the token is valid and returns its underlying lookup query.

        The query returns the user found by the token.
        """
        def verify_user_email_token_query(token, context) do
          case Base.url_decode64(token, padding: false) do
            {:ok, decoded_token} ->
              hashed_token = :crypto.hash(unquote(hash_algorithm), decoded_token)
              days = days_for_context(context)

              query =
                from token in token_and_context_query(hashed_token, context),
                     join: user in assoc(token, :user),
                     where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
                     select: user

              {:ok, query}

            :error ->
              :error
          end
        end

        defp days_for_context("confirm"), do: unquote(confirm_validity_in_days)
        defp days_for_context("reset_password"), do: unquote(reset_password_validity_in_days)

        @doc """
        Checks if the token is valid and returns its underlying lookup query.

        The query returns the user found by the token.
        """
        def verify_user_change_email_token_query(token, context) do
          case Base.url_decode64(token, padding: false) do
            {:ok, decoded_token} ->
              hashed_token = :crypto.hash(unquote(hash_algorithm), decoded_token)

              query =
                from token in token_and_context_query(hashed_token, context),
                     where: token.inserted_at > ago(unquote(change_email_validity_in_days), "day")

              {:ok, query}

            :error ->
              :error
          end
        end

        @doc """
        Returns the given token with the given context.
        """
        def token_and_context_query(token, context) do
          from __MODULE__, where: [token: ^token, context: ^context]
        end

        @doc """
        Gets all tokens for the given user for the given contexts.
        """
        def user_and_contexts_query(user, :all) do
          from t in __MODULE__, where: t.user_id == ^user.id
        end

        def user_and_contexts_query(user, [_ | _] = contexts) do
          from t in __MODULE__, where: t.user_id == ^user.id and t.context in ^contexts
        end
      end
    end
  end
end
