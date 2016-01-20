defmodule ProjectStatus.AuthorisedConn do
  use Phoenix.ConnTest

  def conn_with_session do
    session_opts = Plug.Session.init(store: :cookie, key: "yale", signing_salt: "")
    conn()
    |> Map.put(:secret_key_base, "all your bases " |> String.duplicate(8))
    |> Plug.Session.call(session_opts)
    |> fetch_session()
    |> fetch_flash()
    |> put_req_header("authorization", ProjectStatus.Credentials.encoded) # remove when we take out basic auth
  end

  def authorised_conn do
    conn_with_session() |> Guardian.Plug.sign_in(%{})
  end
end
