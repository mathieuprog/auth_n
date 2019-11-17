defmodule AuthN.Ecto.AuthNFields do
  @moduledoc ~S"""
  Provides macros for defining the fields that are used for user accounts'
  credentials. `identifier_field/1` defines the field storing the login name
  (usually the user's email or username) and `password_field/1` defines the
  field storing the hashed password.
  """

  @callback get_identifier_field() :: atom
  @callback get_password_field() :: atom

  defmacro __using__(_args) do
    this_module = __MODULE__

    quote do
      @behaviour unquote(this_module)

      import unquote(this_module),
        only: [
          identifier_field: 1,
          password_field: 1
        ]

      @before_compile unquote(this_module)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def get_identifier_field(), do: @identifier_field
      def get_password_field(), do: @password_field
    end
  end

  @doc ~S"""
  Defines which field stores the user's login (usually an email or username).
  """
  defmacro identifier_field(field_name) do
    quote do
      field(unquote(field_name), :string)

      Module.put_attribute(__MODULE__, :identifier_field, unquote(field_name))
    end
  end

  @doc ~S"""
  Defines which field is used for the user's password.
  """
  defmacro password_field(field_name) do
    quote do
      field(unquote(field_name), :string)

      Module.put_attribute(__MODULE__, :password_field, unquote(field_name))
    end
  end
end
