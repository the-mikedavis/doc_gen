defmodule DocGen.Content.RandomTest do
  use ExUnit.Case

  alias DocGen.{Content, Content.Video}
  import Content.Random

  describe "private functions:" do
    setup do
      [
        videos: [
          %Video{
            id: 1,
            tags: [%{name: "apple", weight: 1}, %{name: "cat", weight: 1}]
          },
          %Video{
            id: 2,
            tags: [%{name: "bat", weight: 1}, %{name: "cat", weight: 1}]
          },
          %Video{id: 3, tags: []}
        ],
        keywords: ["apple", "bat"],
        scores: [3, 3, 0]
      ]
    end

    test "multiply_keywords/2", context do
      scores =
        context.videos
        |> Enum.map(&multiply_keywords(&1, context.keywords))
        |> Enum.map(& &1.score)

      assert scores == context.scores
    end

    test "score/2", context do
      context.videos
      |> Enum.map(&score(&1, context.keywords))
      |> Enum.zip(context.scores)
      |> Enum.each(fn {%{score: s}, score} ->
        assert score == s
      end)
    end

    test "repeat/3" do
      assert repeat(%{}, 3, []) == [%{}, %{}, %{}]
    end

    test "number_per_segment/1" do
      assert MapSet.new(number_per_segment(1)) == MapSet.new([0, 0, 1])
      assert MapSet.new(number_per_segment(2)) == MapSet.new([0, 1, 1])
      assert number_per_segment(3) == [1, 1, 1]
      assert MapSet.new(number_per_segment(4)) == MapSet.new([1, 1, 2])
      assert MapSet.new(number_per_segment(5)) == MapSet.new([1, 2, 2])
      assert number_per_segment(6) == [2, 2, 2]
      assert MapSet.new(number_per_segment(7)) == MapSet.new([2, 2, 3])
      assert MapSet.new(number_per_segment(8)) == MapSet.new([2, 3, 3])
      assert number_per_segment(9) == [3, 3, 3]
    end
  end
end
