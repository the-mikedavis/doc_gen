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
  end
end
