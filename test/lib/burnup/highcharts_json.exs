defmodule Burnup.HighchartsJsonTest do
  use ExUnit.Case

  import Burnup.HighchartsJson

  test "erl_to_epoch_milliseconds" do
    assert 0 == erl_to_epoch_milliseconds({{1970, 1, 1}, {0, 0, 0}})
    assert 1457796645000 == erl_to_epoch_milliseconds({{2016, 3, 12}, {15, 30, 45}})
    assert 1460377801000 == erl_to_epoch_milliseconds({{2016, 4, 11}, {12, 30, 1}})
  end

  test "highcharts_structured, but quite weakly" do
    categorised_totals = %{
      totals: [],
      delivered: [],
      accepted: []
    }
    assert highcharts_structured(categorised_totals) == %{
      exportFilename: "burnup.png",
      exportTitle: "Burnup",
      xAxisMin: 1463961600000,
      xAxisMax: 1468627199000,
      xAxisTitle: "Date",
      yAxisTitle: "Points",
      series: [%{name: "Total",  data: []},
               %{name: "Total Delivered", data: []},
               %{name: "Accepted", data: []}
              ]
    }
  end

  test "dates converted to epoch times in milliseconds" do
    categorised_totals = %{
      totals: [{{{1970, 1, 1}, {0, 0, 0}}, 30}],
      delivered: [{{{1970, 1, 1}, {0, 1, 0}}, 20}],
      accepted: [{{{1970, 1, 1}, {0, 2, 0}}, 10}]
    }

    %{series: series} = highcharts_structured(categorised_totals)
    assert series == [
      %{name: "Total", data: [{0, 30}]},
      %{name: "Total Delivered", data: [{60000, 20}]},
      %{name: "Accepted", data: [{120000, 10}]},
    ]
  end
end
