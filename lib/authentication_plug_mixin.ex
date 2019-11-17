defmodule AuthN.AuthenticationPlugMixin do
  @moduledoc ~S"""
  Allows to create a plug enforcing authentication for private routes.

  A user-defined module must `use` this module, making the user module a plug, and
  implement the `handle_authentication_error/2` behaviour. The
  `handle_authentication_error/2` callback receives a `Plug.Conn` struct and an
  atom identifying the set of routes that require authentication, and must return
  a `Plug.Conn` struct.

  Example:

    ```
    defmodule MyAppWeb.Plugs.EnsureAuthenticated do
      use AuthN.AuthenticationPlugMixin

      import Plug.Conn
      import Phoenix.Controller

      def handle_authentication_error(conn, :admin_routes),
        do: conn |> put_status(401) |> text("unauthenticated") |> halt()
    end
    ```

    `EnsureAuthenticated` is now a plug which can be used in the router:

    ```
    pipeline :ensure_admin_routes_authorized do
      plug MyAppWeb.Plugs.EnsureAuthenticated,
        resource: :admin_routes
    end

    scope "/admin", MyAppWeb, as: :admin do
      pipe_through [:browser, :ensure_admin_routes_authorized]
      # code
    end
    ```
  """

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
