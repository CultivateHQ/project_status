defmodule Trello.Fetch do
  @user_agent  [ {"User-agent", "Elixir for Trello"} ]
  @base_url "https://trello.com/1"

  def fetch(command = {_, _}) do
    fetch(command, Trello.Credentials.credentials)
  end

  def fetch(command = {request_type, _}, credentials) do
    url(command, credentials)
    |> HTTPotion.get # For some reason Trello hates HTTPoison
    |> handle_response(request_type)
  end

  def handle_response(%{status_code: 200, body: body}, request_type) do
    {request_type, Poison.decode!(body) }
  end

  def handle_response(%{status_code: status_code, body: body}, _) do
    {:error, %{status_code: status_code, body: body}}
  end


  def url(command, {key, token}) do
    case command do
      {:board_name,  board_id} -> "#{@base_url}/boards/#{board_id}/name?key=#{key}&token=#{token}"
      {:board_cards,  board_id} -> "#{@base_url}/boards/#{board_id}/name?key=#{key}&token=#{token}"
      {:board_lists, board_id} -> "#{@base_url}/boards/#{board_id}/lists?cards=open&card_fields=name&key=#{key}&token=#{token}"
      {:card_list_changes, card_id} -> "#{@base_url}/cards/#{card_id}/actions?filter=updateCard:idList&key=#{key}&token=#{token}"
      {:board_list_cards, list_id} -> "#{@base_url}/lists/#{list_id}/cards?fields=name,desc,url&key=#{key}&token=#{token}"
    end

  end
end
