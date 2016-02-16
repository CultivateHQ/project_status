defmodule ProjectStatus.Router do
  use ProjectStatus.Web, :router
  use Honeybadger.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticated do
    plug Guardian.Plug.EnsureAuthenticated, handler: ProjectStatus.SessionController
  end

  pipeline :ueberauth do
    plug Ueberauth
  end

  scope "/auth", ProjectStatus do
    pipe_through [:browser, :ueberauth]

    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :callback
  end

  scope "/session", ProjectStatus do
    pipe_through [:browser]

    get "/new", SessionController, :new
    delete "/delete", SessionController, :delete
  end

  scope "/", ProjectStatus do
    pipe_through [:browser, :authenticated]

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/status_emails", StatusEmailController, only: [:show]
    end
  end
end
