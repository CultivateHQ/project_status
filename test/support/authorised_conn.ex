defmodule ProjectStatus.AuthorisedConn do
  use Phoenix.ConnTest

  def authorised_conn do
    session_opts = Plug.Session.init(store: :cookie, key: "yale", signing_salt: "")
    conn()
    |> put_req_header("authorization", ProjectStatus.Credentials.encoded)
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session()
    |> Guardian.Plug.sign_in(%{})
  end
end
