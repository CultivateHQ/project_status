defmodule TrelloDecodeTest do
  use ExUnit.Case
  import Trello.Decode

@board_list [%{"cards" => [%{"id" => "563af1539a5565452c0b3cda", "name" => "Landing page"},
    %{"id" => "54edc048e430432df9959284",
      "name" => "Distinguish between questions directed at advisers and clients"},
    %{"id" => "563af77a49dd19382cadc1e5", "name" => "Pre-assessment page"},
    %{"id" => "563bf017a167ea40f2142c4c", "name" => "Session Timeout"}],
   "closed" => false, "id" => "55cdb982dda23d6d2914fcf2",
   "idBoard" => "54eafa291c316f2112ce7365", "name" => "Master backlog",
   "pos" => 49151.25, "subscribed" => false},
 %{"cards" => [%{"id" => "5649bc24cf2469db904e54a4",
      "name" => "[5] Implement channel validation flow"},
    %{"id" => "5649bc82ff2ecf20d2fdee72", "name" => "[3] Answer hints"},
    %{"id" => "56558fea312d79e64a7d2601",
      "name" => "[1] Swap DNS and SSL certs to cia.moneyadviceservice.org.uk"},
    %{"id" => "56570efd2a378ce53c5d3460",
      "name" => "Mark the time an assessment is completed at"}],
   "closed" => false, "id" => "54edbf13a590ea1f0d47a523",
   "idBoard" => "54eafa291c316f2112ce7365", "name" => "To Do", "pos" => 65535,
   "subscribed" => false},
 %{"cards" => [%{"id" => "5649bb0280afb8d010444464",
      "name" => "[3] Fully styled landing page with all content"},
    %{"id" => "5649bade0f4a2216cd17dd14", "name" => "[5] Deploy to production"},
    %{"id" => "564f4a65aaad9a9538ddb9ec",
      "name" => "[2] Set up SSH on production server"}], "closed" => false,
   "id" => "54ef1a0b792ce91b05c59de1", "idBoard" => "54eafa291c316f2112ce7365",
   "name" => "Blocked", "pos" => 131071, "subscribed" => false}]


  test "sums up the story points in each board" do
     assert [{"Master backlog", 0}, {"To Do", 9}, {"Blocked", 10}] == sum_story_points(@board_list)
  end

  test "split name into points and name" do
    assert {nil, "bob"} == split_name_into_points_and_name("bob")
    assert {nil, "[1 bob"} == split_name_into_points_and_name("[1 bob")
    assert {nil, "[1x] bob"} == split_name_into_points_and_name("[1x] bob")

    assert {1, "bob"} == split_name_into_points_and_name("[1]bob")
    assert {1, "bob"} == split_name_into_points_and_name("  [1]bob")
    assert {1, "bob"} == split_name_into_points_and_name("  [1]  bob    ")
    assert {1, "bob martin"} == split_name_into_points_and_name("  [1]  bob martin   ")
  end
end
