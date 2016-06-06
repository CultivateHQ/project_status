defmodule Burnup.HighchartsJson do

  @epoch_gregorian_seconds :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})

  @x_title "Date"
  @y_title "Points"
  @filename "burnup.png"
  @title "Burnup"

  # This is just for proof of concept
  @x_min {{2016, 5, 23}, {0, 0, 0}}
  @x_max {{2016, 7, 15}, {23, 59, 59}}

  def highcharts_structured(categorised_totals) do
    %{
      series: series(categorised_totals),
      xAxisMax: @x_max |> erl_to_epoch_milliseconds,
      xAxisMin: @x_min |> erl_to_epoch_milliseconds,
      xAxisTitle: @x_title,
      yAxisTitle: @y_title,
      exportFilename: @filename,
      exportTitle: @title
    }
  end

  def series(%{totals: totals, delivered: delivered, accepted: accepted}) do
    [%{name: "Total",  data: totals_with_epoch_date(totals)},
     %{name: "Total Delivered", data: totals_with_epoch_date(delivered)},
     %{name: "Accepted", data: totals_with_epoch_date(accepted)}
    ]
  end

  def totals_with_epoch_date(totals) do
    totals
    |> Enum.map(fn {datetime, total} -> {erl_to_epoch_milliseconds(datetime), total} end)
  end

  def highcharts_json(categorised_totals) do
    categorised_totals
    |> highcharts_structured
    |> Poison.encode!
  end

  def erl_to_epoch_milliseconds(datetime = {{_,_,_},{_,_,_}}) do
    (:calendar.datetime_to_gregorian_seconds(datetime) - @epoch_gregorian_seconds) * 1000
  end
end
