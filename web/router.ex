defmodule ProjectStatus.Router do
  use ProjectStatus.Web, :router

  import ProjectStatus.Credentials, only: [username: 0, password: 0]
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BasicAuth, {:application_config, :basic_auth}
  end

  scope "/", ProjectStatus do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/projects", ProjectController do
      resources "/status_emails", StatusEmailController, only: [:show]
    end
  end
end
