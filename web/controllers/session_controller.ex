defmodule ProjectStatus.SessionController do
  use ProjectStatus.Web, :controller

  @team_membership_required_id 973593

  def unauthenticated(conn, _params) do
    conn
    |> redirect(to: session_path(conn, :new))
  end

  def new(conn, _params) do
    conn
    |> render("new.html")
  end

  def delete(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end

  def callback(conn = %{assigns: %{ueberauth_auth: auth=%{uid: uid}} }, _params) do
    conn
    |> Guardian.Plug.sign_in(%{github_uid: uid})
    |> put_flash(:info, "Signed in #{uid}")
    |> redirect(to: "/")
  end

  def callback(conn = %{assigns: %{ueberauth_failure: _}}, _params) do
    conn
    |> put_flash(:error, "Failed to sign in")
    |> redirect(to: "/")
  end
end
