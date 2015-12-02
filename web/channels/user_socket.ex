defmodule ProjectStatus.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "project_email_recipients:*", ProjectStatus.ProjectEmailRecipientChannel
  channel "project_status_emails:*", ProjectStatus.ProjectStatusEmailChannel
  channel "trellos:*", ProjectStatus.TrelloChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  @two_weeks_in_seconds 1209600

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  #  To deny connection, return `:error`.
  def connect(%{"token" => token}, socket) do
    creds = ProjectStatus.Credentials.encoded
    case Phoenix.Token.verify(socket, "creds", token, max_age: @two_weeks_in_seconds) do
      {:ok, ^creds} -> {:ok, socket}
      {:error, _} -> :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     MyApp.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
