defmodule ProjectStatus.StatusEmailDates do
  import Chronos, only: [days_ago: 1]
  import Chronos.Formatter, only: [strftime: 2]

  def dates do
    (4..0)
      |> Enum.map(&({days_ago(&1), &1 == 0}))
      |> Enum.map(fn {date, is_today} -> {date, date |> strftime("%Y-%0m-%0d"), is_today |> selected_if_true} end)
  end

  defp selected_if_true true do
    "selected"
  end
  defp selected_if_true _ do
    ""
  end
end
