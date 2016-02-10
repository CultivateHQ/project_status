defmodule ProjectStatus.Trello do
  use GenServer

  @moduledoc """
  Serialise requests to Trello, as it can get shirty about too many.
  """

  import Trello.Fetch, only: [fetch: 1]
  import Trello.Decode, only: [sum_story_points: 1]

  @name __MODULE__

  def start_link do
    GenServer.start_link(__MODULE__, {}, [name: @name])
  end

  ## API

  def sum_points_for_board(board_id) do
     @name |> GenServer.call({:sum_points_for_board, board_id})
  end

  def fetch_board_lists(board_id) do
    @name |> GenServer.call({:fetch, {:board_lists, board_id}})
  end


  ## GenServer

  def handle_call({:fetch, command = {command_type, _id}}, _from, state) do
    {command_type, results} = fetch(command)
    {:reply, {:ok, results}, state}
  end

  def handle_call({:sum_points_for_board, board_id}, _from, state) do
    reply = case fetch({:board_lists, board_id}) do
      {:board_lists, board_data} -> {:ok, sum_story_points(board_data)}
      err -> err
    end
    {:reply, reply, state}
  end
end
