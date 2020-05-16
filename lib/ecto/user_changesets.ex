defmodule AuthN.Ecto.UserChangesets do
  @callback registration_changeset(struct, map, struct) :: atom
  @callback email_changeset(struct, map, struct) :: atom
  @callback password_changeset(struct, map) :: atom
  @callback confirm_changeset(struct) :: atom
  @callback validate_current_password(struct, String.t) :: atom

  defmacro __using__(opts) do
    fields = Keyword.get(opts, :fields, [])
    email_field = Keyword.get(fields, :email, :email)
    hashed_password_field = Keyword.get(fields, :hashed_password, :hashed_password)
    clear_password_field = Keyword.get(fields, :clear_password, :clear_password)
    confirmed_at_field = Keyword.get(fields, :confirmed_at, :confirmed_at)
    hashing_module = Keyword.get(opts, :hashing_module, Argon2)

    this_module = __MODULE__

    quote do
      import Ecto.Changeset

      @behaviour unquote(this_module)

      @doc """
      A user changeset for registration.

      It is important to validate the length of both e-mail and password.
      Otherwise databases may truncate the e-mail without warnings, which
      could lead to unpredictable or insecure behaviour. Long passwords may
      also be very expensive to hash for certain algorithms.
      """
      def registration_changeset(user, attrs, ecto_repo) do
        user
        |> cast(attrs, [unquote(email_field), unquote(clear_password_field)])
        |> validate_email(ecto_repo)
        |> validate_password()
      end

      defp validate_email(changeset, ecto_repo) do
        changeset
        |> validate_required([unquote(email_field)])
        |> validate_format(unquote(email_field), ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
        |> validate_length(unquote(email_field), max: 160)
        |> unsafe_validate_unique(unquote(email_field), ecto_repo)
        |> unique_constraint(unquote(email_field))
      end

      defp validate_password(changeset) do
        changeset
        |> validate_required([unquote(clear_password_field)])
        |> validate_length(unquote(clear_password_field), min: 10, max: 80)
          # |> validate_format(unquote(clear_password_field), ~r/[a-z]/, message: "at least one lower case character")
          # |> validate_format(unquote(clear_password_field), ~r/[A-Z]/, message: "at least one upper case character")
          # |> validate_format(unquote(clear_password_field), ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
        |> prepare_changes(&maybe_hash_password/1)
      end

      defp maybe_hash_password(changeset) do
        if password = get_change(changeset, unquote(clear_password_field)) do
          changeset
          |> put_change(unquote(hashed_password_field), unquote(hashing_module).hash_pwd_salt(password))
          |> delete_change(unquote(clear_password_field))
        else
          changeset
        end
      end

      @doc """
      A user changeset for changing the e-mail.

      It requires the e-mail to change otherwise an error is added.
      """
      def email_changeset(user, attrs, ecto_repo) do
        user
        |> cast(attrs, [unquote(email_field)])
        |> validate_email(ecto_repo)
        |> case do
             %{changes: %{unquote(email_field) => _}} = changeset -> changeset
             %{} = changeset -> add_error(changeset, unquote(email_field), "did not change")
           end
      end

      @doc """
      A user changeset for changing the password.
      """
      def password_changeset(user, attrs) do
        user
        |> cast(attrs, [unquote(clear_password_field)])
        |> validate_confirmation(unquote(clear_password_field), message: "does not match password")
        |> validate_password()
      end

      @doc """
      Confirms the account by setting `confirmed_at`.
      """
      def confirm_changeset(user) do
        now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        change(user, [{unquote(confirmed_at_field), now}])
      end

      @doc """
      Validates the current password otherwise adds an error to the changeset.
      """
      def validate_current_password(changeset, password) do
        if valid_password?(changeset.data, password) do
          changeset
        else
          add_error(changeset, :current_password, "is not valid")
        end
      end

      defoverridable confirm_changeset: 1,
                     email_changeset: 3,
                     password_changeset: 2,
                     registration_changeset: 3,
                     validate_current_password: 2
    end
  end
end
