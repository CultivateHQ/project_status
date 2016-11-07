columns = [
  {"Icebox", "571f3a15c3d786e3e8e27f46"},
  {"For estimate", "5739bc0f499c46936858fc91"},
  {"Needs more information", "571f31ffb4a28bd8b1a7b9e3"},
  {"Backlog", "571f31ffb4a28bd8b1a7b9e2"},
  {"Doing", "571f31ffb4a28bd8b1a7b9e5"},
  {"CultivateQA", "571f31ffb4a28bd8b1a7b9e6"},
  {"Finished", "571f31ffb4a28bd8b1a7b9e7"},
  {"Accepted", "571f31ffb4a28bd8b1a7b9e8"},
]

ids = columns |> Enum.map(fn {_n, id} -> id end)
names = columns |> Enum.map(fn {n, _id} -> n end)

format_date = fn {{year, month, day}, {_h,_m,_s}} ->
  "#{day}/#{month}/#{year}"
end

find_total = fn find_id, totals ->
  totals
  |> Enum.find({0}, fn {_date, id, _name, _count} -> id == find_id end)
  |> Tuple.to_list
  |> Enum.reverse
  |> hd || 0
end

flatten_totals = fn totals ->
  ids
  |> Enum.map(fn id ->
    find_total.(id, totals)
  end)
end

date_and_totals = fn date, totals ->
  [format_date.(date) | flatten_totals.(totals)]
end

IO.inspect names

[names |
13
|> Burnup.Queries.raw_totals
|> Enum.group_by(fn {date, _id, _name, _count} -> date end)
|> Enum.map(fn {date, totals} -> date_and_totals.(date, totals) end)]
|> Enum.map(fn row -> row |> Enum.join("\t") end)
|> Enum.join("\n")
|> IO.puts
