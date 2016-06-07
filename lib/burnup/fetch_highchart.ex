defmodule Burnup.FetchChart do
  @export_url "http://export.highcharts.com/"

  def fetch(highcharts_json_structure) do
    {:ok, json} = %{options: highcharts_json_structure, type: 'image/png'} |> Poison.encode
    @export_url
    |> HTTPoison.post(json)
  end

  def test_uc do
    categories = Burnup.Queries.story_status_categories(13)
    13
    |> Burnup.Queries.raw_totals
    |> Burnup.Queries.categorise_totals(categories)
    |> Burnup.HighchartsJson.highcharts_structured
    |> fetch

  end
end
