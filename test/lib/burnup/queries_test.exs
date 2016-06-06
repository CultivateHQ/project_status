defmodule Burnup.QueriesTest do
  use ExUnit.Case
  import Burnup.Queries, only: [categorise_totals: 2]

  @status_categories %{"571f31ffb4a28bd8b1a7b9e2" => "todo", #1
                       "571f31ffb4a28bd8b1a7b9e3" => "todo", #2
                       "571f31ffb4a28bd8b1a7b9e5" => "todo", #3
                       "571f31ffb4a28bd8b1a7b9e6" => "todo", #4
                       "571f31ffb4a28bd8b1a7b9e7" => "done",
                       "571f31ffb4a28bd8b1a7b9e8" => "accepted",
                       "571f31ffb4a28bd8b1a7b9e9" => "accepted"}

  @raw_totals [{{{2016, 6, 4}, {7, 43, 33}}, "571f3a15c3d786e3e8e27f46", "Not categorised", 17},
               {{{2016, 6, 4}, {7, 43, 33}}, "571f31ffb4a28bd8b1a7b9e2", "todo 1", 32},
               {{{2016, 6, 4}, {7, 43, 33}}, "571f31ffb4a28bd8b1a7b9e3", "todo 2", 23},
               {{{2016, 6, 4}, {7, 43, 33}}, "571f31ffb4a28bd8b1a7b9e7", "done", 8},
               {{{2016, 6, 4}, {7, 43, 33}}, "571f31ffb4a28bd8b1a7b9e8", "accepted", 1},
               {{{2016, 6, 4}, {7, 43, 33}}, "571f31ffb4a28bd8b1a7b9e9", "super accepted", 1},

               {{{2016, 6, 3}, {3, 39, 39}}, "571f31ffb4a28bd8b1a7b9e2", "todo 1", 55},
               {{{2016, 6, 3}, {3, 39, 39}}, "571f31ffb4a28bd8b1a7b9e5", "todo 3", 6},
               {{{2016, 6, 3}, {3, 39, 39}}, "571f31ffb4a28bd8b1a7b9e6", "todo 4", 1},
               {{{2016, 6, 3}, {3, 39, 39}}, "571f31ffb4a28bd8b1a7b9e7", "done",  1},

               {{{2016, 6, 2}, {3, 30, 53}}, "571f31ffb4a28bd8b1a7b9e2", "todo 1", 55},
               {{{2016, 6, 2}, {3, 30, 53}}, "571f31ffb4a28bd8b1a7b9e5", "todo 3", 7},
               {{{2016, 6, 2}, {3, 30, 53}}, "571f31ffb4a28bd8b1a7b9e6", "todo 4", 1},
               {{{2016, 6, 2}, {3, 30, 53}}, "571f31ffb4a28bd8b1a7b9e7", "done", nil},
              ]


  test "categorise totals" do
    categorised_totals = categorise_totals(@raw_totals, @status_categories)
    assert categorised_totals.total == [{{{2016, 6, 2}, {3, 30, 53}}, 55 + 7 + 1},
                                        {{{2016, 6, 3}, {3, 39, 39}}, 55 + 6 + 1 + 1},
                                        {{{2016, 6, 4}, {7, 43, 33}}, 32 + 23 + 8 + 2}]
    assert categorised_totals.delivered == [{{{2016, 6, 2}, {3, 30, 53}}, 0},
                                           {{{2016, 6, 3}, {3, 39, 39}}, 1},
                                           {{{2016, 6, 4}, {7, 43, 33}}, 8 + 2}]

    assert categorised_totals.accepted == [{{{2016, 6, 4}, {7, 43, 33}}, 2}]

  end

  test "categorise totals with empty totals" do
    assert %{total: [], delivered: [], accepted: []} == categorise_totals([], @status_categories)
  end

end
