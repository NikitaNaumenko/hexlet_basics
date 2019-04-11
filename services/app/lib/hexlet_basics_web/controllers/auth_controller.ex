defmodule HexletBasicsWeb.AuthController do
  use HexletBasicsWeb, :controller
  alias HexletBasics.Repo
  alias HexletBasics.{User}
  plug Ueberauth

  alias Ueberauth.Strategy.Helpers

  def request(conn, _params) do
    render(conn, callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, gettext "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, gettext "Failed to authenticate.")
    |> configure_session(drop: true)
    |> redirect(to: page_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    maybe_user = Repo.get_by(User, github_uid: auth.uid)
    user = case maybe_user do
      nil -> %User{github_uid: auth.uid}
      entity -> entity
    end
    user = user
           |> User.changeset(%{
             nickname: auth.info.nickname,
             email: auth.info.email
           })
           |> Repo.insert_or_update!


    conn
      |> put_flash(:info, gettext "Successfully authenticated.")
      |> put_session(:current_user, user)
      |> redirect to: HexletBasicsWeb.Plugs.Navigation.previous_path(conn, default: "/")
  end
end
