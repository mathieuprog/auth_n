# AuthN

AuthN is a simple authentication library that allows you to

* authenticate a user against a database;
* maintain the user logged in;
* ensure private routes are accessed by logged in users only;
* use view helpers to access the logged in user from templates.

## Authenticate the user

In your Schema representing the user accounts, specify which are the username and
password fields using the `identifier_field/1` and `password_field/1` macros:

```elixir
use AuthN.Ecto.AuthNFields

schema "users" do
  identifier_field :email
  password_field :password_hash
  field :name, :string
  field :active, :boolean
end
```

`DBAuthenticator.authenticate/3` allows you to authenticate the user against the
database. The first two arguments are the username and password, and the third
argument is a tuple containing your Repo module name and the user account Schema
struct. This function is typically called in the controller action handling login
submissions; the email and password being provided by the user through a login form.

```elixir
alias AuthN.Authenticator.DBAuthenticator

case DBAuthenticator.authenticate(email, password, {MyApp.Repo, MyApp.Accounts.User}) do
  {:ok, user} ->
    conn
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: Routes.profile_path(conn, :index))

  {:error, :unknown_user} ->
    conn
    |> put_flash(:error, "No account found with that email address.")
    |> render("new.html")

  {:error, :wrong_password} ->
    conn
    |> put_flash(:error, "Invalid password")
    |> render("new.html")
end
```

By default, the library will use the `Argon2` hash function to verify passwords.
`Argon2` is recommended over `bcrypt`.See
[argon2_elixir](https://github.com/riverrun/argon2_elixir). You may change the
default password-hashing function through the `:hashing_module` option, by passing
it a module name which implements the `Comeonin` and `Comeonin.PasswordHash`
behaviours from the [comeonin](https://github.com/riverrun/comeonin) library, such
as [bcrypt_elixir](https://github.com/riverrun/bcrypt_elixir).

In most situations you do not want to reveal if the account exists in case of a
failed authentication:

```elixir
case DBAuthenticator.authenticate(email, password, {MyApp.Repo, MyApp.Accounts.User}) do
  {:ok, user} ->
    conn
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: Routes.admin_question_path(conn, :index))
  _ ->
    conn
    |> put_flash(:error, "Invalid username/password combination")
    |> render("new.html")
end
```

Rather than calling `DBAuthenticator.authenticate/3` from the controller, one can
instead call it from the context. Not only this is cleaner as the Repo should
preferably only be known by the context, but one can also add additional 
application-specific authentication logic such as verifying if the user account
has been locked:

```elixir
def authenticate(email, password) do
  case DBAuthenticator.authenticate(email, password, {Repo, User}) do
    {:ok, %{:active => true} = user} ->
      {:ok, user}

    {:ok, _} ->
      {:error, :inactive_user}

    error ->
      error
  end
end
```

## Maintain the user logged in

After a successful authentication, the user ID should be stored into session in
order to identify the logged user on subsequent requests.

`SessionStorage.put_user_id/1` stores the user ID into the session.

```elixir
alias AuthN.SessionStorage

case DBAuthenticator.authenticate(email, password, {MyApp.Repo, MyApp.Accounts.User}) do
  {:ok, user} ->
    conn
    |> SessionStorage.put_user_id(user.id)
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: Routes.profile_path(conn, :index))
  # code
end
```

> **Note:** By default, the session is stored in a stateless cookie. The library
> uses the functions from `Plug` to handle data in session, such as
> `Plug.Conn.put_session/2`, `Plug.Conn.get_session/2`,
> `Plug.Conn.configure_session/1`, ...

Once the user ID has been stored into the session, the user can be retrieved by
the `AuthN.Plugs.AssignCurrentUser` plug:

```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_flash
  plug :protect_from_forgery
  plug :put_secure_browser_headers

  plug AuthN.Plugs.AssignCurrentUser,
    fetch_user: &MyApp.Accounts.get_user/1
end
```

The `AssignCurrentUser` plug stores the logged in user into `conn.assigns` under
the `:current_user` key. The user is fetched by a user-defined function provided
to the plug, through the `:fetch_user` option, and receiving the user ID as
argument.

## Protecting routes against unauthenticated users

Authentication can be enforced for some routes. Create a module using (`use`) the
`AuthN.AuthenticationPlugMixin` module; then implement the callback
`handle_authentication_error/2` receiving a `Plug.Conn` struct and an atom
identifying the set of routes that require authentication:

```elixir
defmodule MyAppWeb.Plugs.EnsureAuthenticated do
  use AuthN.AuthenticationPlugMixin

  import Plug.Conn
  import Phoenix.Controller

  def handle_authentication_error(conn, :admin_routes),
    do: conn |> put_status(401) |> text("unauthenticated") |> halt()
end
```

You may then use the new plug into a pipeline and ensure that routes requiring
authentication are accessed by logged in users only.

```elixir
pipeline :ensure_admin_routes_authorized do
  plug MyAppWeb.Plugs.EnsureAuthenticated,
    resource: :admin_routes
end

scope "/admin", MyAppWeb, as: :admin do
  pipe_through [:browser, :ensure_admin_routes_authorized]
  # code
end
```

## Installation

Add `auth_n` for Elixir as a dependency in your `mix.exs` file:

```elixir
def deps do
  [
    {:auth_n, "~> 0.2.0"}
  ]
end
```

## HexDocs

HexDocs documentation can be found at [https://hexdocs.pm/auth_n](https://hexdocs.pm/auth_n).
