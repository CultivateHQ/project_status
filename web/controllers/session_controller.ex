defmodule ProjectStatus.SessionController do
  use ProjectStatus.Web, :controller
  require Logger

  @authorisation_github_team_id Application.get_env(:project_status, :authorisation_github_team_id)

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

  def callback(conn = %{assigns: %{ueberauth_auth: %{uid: uid, credentials: %{token: token}}}}, _params) do
    HTTPoison.get("https://api.github.com/teams/#{@authorisation_github_team_id}/memberships/#{uid}?access_token=#{token}")
    |> in_authenticated_team(conn, uid)
  end

  def callback(conn = %{assigns: %{ueberauth_failure: _}}, _params) do
    conn
    |> put_flash(:error, "Failed to sign in")
    |> redirect(to: "/")
  end

  defp in_authenticated_team({:ok, %HTTPoison.Response{status_code: 200}}, conn, uid) do
    conn
    |> Guardian.Plug.sign_in(%{github_uid: uid})
    |> put_flash(:info, "Signed in #{uid}.")
    |> redirect(to: "/")
  end


  defp in_authenticated_team({:ok, %HTTPoison.Response{status_code: status_code}}, conn, uid) when status_code == 404 or status_code == 401 do
    conn
    |> put_flash(:info, "Sorry, #{uid}, you do not have access permissions.")
    |> redirect(to: "/")
  end

  defp in_authenticated_team(response, conn, uid) do
    Logger.error("unexpected response from Google when checking team membership: #{response |> inspect}")
    conn
    |> put_flash(:info, "Sorry, #{uid}, something went wrong authorising you.")
    |> redirect(to: "/")
  end
end
