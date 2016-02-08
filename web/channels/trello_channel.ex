defmodule ProjectStatus.TrelloChannel do
  use ProjectStatus.Web, :channel
  alias ProjectStatus.Trello

  def join("trellos:"<>trello_project_id, _payload, socket) do
    send(self, :read_trellos)
    {:ok, socket |> assign(:trello_project_id, trello_project_id)}
  end

  def handle_info(:read_trellos, socket) do
    case Trello.sum_points_for_board(socket.assigns.trello_project_id) do
      {:ok, totals} -> push socket, "trello_totals", %{totals: totals |> Enum.map(fn {name, total} -> [name, total] end)}
      {:error, err} -> push socket, "trello_totals_error", %{error: err |> inspect}
    end
    {:noreply, socket}
  end
end
