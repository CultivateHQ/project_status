defmodule ProjectStatus.PageControllerTest do
  use ProjectStatus.ConnCase

  test "GET /" do
    conn = get authorised_conn(), "/"
    assert redirected_to(conn) == project_path(conn, :index)
  end

end
