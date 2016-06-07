defmodule Burnup.HighchartsJsonTest do
  use ExUnit.Case

  import Burnup.HighchartsJson

  test "erl_to_epoch_milliseconds" do
    assert 0 == erl_to_epoch_milliseconds({{1970, 1, 1}, {0, 0, 0}})
    assert 1457796645000 == erl_to_epoch_milliseconds({{2016, 3, 12}, {15, 30, 45}})
    assert 1460377801000 == erl_to_epoch_milliseconds({{2016, 4, 11}, {12, 30, 1}})
  end

  test "dates converted to epoch times in milliseconds" do
    categorised_totals = %{
      total: [{{{1970, 1, 1}, {0, 0, 0}}, 30}],
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
