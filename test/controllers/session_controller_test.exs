defmodule ProjectStatus.SessionControllerTest do
  use ProjectStatus.ConnCase
  require IEx
  import Mock

  @team_id Application.get_env(:project_status, :authorisation_github_team_id)

  test "authorised user that is in authorisation team is signed in" do
    with_mock HTTPoison, [get: fn(_url) -> {:ok, github_team_response(200)} end] do

      connection = ProjectStatus.SessionController.callback(authorised_connection_for_callback, %{})

      assert {:ok, _} = Guardian.Plug.claims(connection) # signed in
      assert redirected_to(connection) == "/"
      assert get_flash(connection) == %{"info" => "Signed in mavis."}
    end
  end

  test "authorised user that is not in authorisation team is not signed in" do
    with_mock HTTPoison, [get: fn(_url) -> {:ok, github_team_response(404)} end] do
      connection = ProjectStatus.SessionController.callback(authorised_connection_for_callback, %{})

      assert {_, :no_session} = Guardian.Plug.claims(connection) # not signed in
      assert redirected_to(connection) == "/"
      assert get_flash(connection) == %{"info" => "Sorry, mavis, you do not have access permissions."}
    end
  end

  test "authorised user that does not have access to the read the team is not signed in" do
    with_mock HTTPoison, [get: fn(_url) -> {:ok, github_team_response(401)} end] do
      connection = ProjectStatus.SessionController.callback(authorised_connection_for_callback, %{})

      assert {_, :no_session} = Guardian.Plug.claims(connection) # not signed in
      assert redirected_to(connection) == "/"
      assert get_flash(connection) == %{"info" => "Sorry, mavis, you do not have access permissions."}
    end
  end

  test "authorised user, but response from Github has an unexpected error code" do
    with_mock HTTPoison, [get: fn(_url) -> {:ok, github_team_response(418)} end] do
      connection = ProjectStatus.SessionController.callback(authorised_connection_for_callback, %{})

      assert {_, :no_session} = Guardian.Plug.claims(connection) # not signed in
      assert redirected_to(connection) == "/"
      assert get_flash(connection) == %{"info" => "Sorry, mavis, something went wrong authorising you."}
    end
  end

  test "authorised user, but the request for team membership fails with error" do
    with_mock HTTPoison, [get: fn(_url) -> {:error, :eh} end] do
      connection = ProjectStatus.SessionController.callback(authorised_connection_for_callback, %{})

      assert {_, :no_session} = Guardian.Plug.claims(connection) # not signed in
      assert redirected_to(connection) == "/"
      assert get_flash(connection) == %{"info" => "Sorry, mavis, something went wrong authorising you."}
    end
  end

  defp authorised_connection_for_callback do
    conn_with_session()
    |> Map.put(:assigns,
               %{ueberauth_auth: %{uid: "mavis",
                                   credentials: %{token: "123"}}})
  end

  defp github_team_response(code) do
    %HTTPoison.Response{status_code: code}
  end
end
