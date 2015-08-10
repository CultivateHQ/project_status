defmodule ProjectStatus.Router do
  use ProjectStatus.Web, :router


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Blaguth, realm: "secret", credentials: {"ARSE", "arse"}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProjectStatus do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/status_emails", StatusEmailController, only: [:show]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ProjectStatus do
  #   pipe_through :api
  # end
end
