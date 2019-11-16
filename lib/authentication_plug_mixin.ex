defmodule AuthN.AuthenticationPlugMixin do
  @callback handle_authentication_error(Plug.Conn.t(), atom) :: Plug.Conn.t()

  defmacro __using__(_args) do
    this_module = __MODULE__

    quote do
      @behaviour unquote(this_module)

      def init(opts), do: opts

      def call(conn, opts) do
        if AuthN.SessionStorage.get_user_id(conn) do
          conn
        else
          __MODULE__.handle_authentication_error(conn, Keyword.get(opts, :resource))
        end
      end
    end
  end
end
