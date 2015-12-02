defmodule TuplePoisonEncoderTest do
  use ExUnit.Case

  test "encoding double tuple" do
    assert {:ok, "[\"hello\"]"} == {"hello"} |> Poison.encode([])
    assert {:ok, "[\"hello\",\"matey\"]"} == {"hello", "matey"} |> Poison.encode([])
  end
end
