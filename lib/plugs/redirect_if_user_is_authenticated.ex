defmodule AuthN.Plugs.RedirectIfUserIsAuthenticated do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts) do
    Keyword.fetch!(opts, :redirect_to_fun)
    opts
  end

  def call(conn, opts) do
    redirect_to_fun = Keyword.fetch!(opts, :redirect_to_fun)

    if conn.assigns[:current_user] do
      conn
      |> redirect(to: redirect_to_fun.(conn))
      |> halt()
    else
      conn
    end
  end
end
