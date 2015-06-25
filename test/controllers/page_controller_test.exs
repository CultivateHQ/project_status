defmodule ProjectStatus.PageControllerTest do
  use ProjectStatus.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert redirected_to(conn) == project_path(conn, :index)
  end
end
