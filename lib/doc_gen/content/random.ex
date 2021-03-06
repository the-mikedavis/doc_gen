defmodule DocGen.Content.Random do
  use Private

  @moduledoc """
  Gives random videos based on the weight and lengths of videos and tags.
  """

  @keyword_multiplier Application.fetch_env!(:doc_gen, :keyword_multiplier)

  alias DocGen.{Content, Repo}

  @doc """
  Gives a random set of videos given a number of clips and a list of keywords.
  """
  @spec give([String.t()], [non_neg_integer()]) ::
          {[non_neg_integer()], non_neg_integer()}
  def give(keywords, number_per_segment) do
    Content.list_segments_with_videos()
    |> Enum.map(& &1.videos)
    |> Enum.zip(number_per_segment)
    |> Enum.map(&take_random(&1, keywords))
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce({[], 0}, fn v, {video_ids, length} ->
      {[v.id | video_ids], length + v.duration}
    end)
  end

  private do
    # take `n` videos randomly proportional to the keyword matches

    @spec take_random({[%Content.Video{}], non_neg_integer()}, [String.t()]) ::
            [%{}]
    defp take_random({videos, number_to_take}, keywords) do
      {videos, _left_behind_videos} =
        Enum.reduce(1..number_to_take, {[], videos}, fn
          _n, {_taken, []} = acc ->
            acc

          _n, {taken, videos} ->
            hot_take = take_a_random(videos, keywords)

            {[hot_take | taken], Enum.reject(videos, &(&1.id == hot_take.id))}
        end)

      videos
    end

    defp take_a_random(videos, keywords) do
      videos
      |> Enum.map(&score(&1, keywords))
      |> Enum.map(&repeat(&1, &1.score, []))
      |> List.flatten()
      |> Enum.random()
    end

    @spec score(%Content.Video{}, [String.t()]) :: %{}
    defp score(video, keywords) do
      video
      |> Repo.preload(:tags)
      |> Map.from_struct()
      |> multiply_keywords(keywords)
    end

    @spec repeat(%{}, non_neg_integer(), [%{}]) :: [%{}]
    defp repeat(_v, 0, acc), do: acc
    defp repeat(video, n, acc), do: repeat(video, n - 1, [video | acc])

    @spec multiply_keywords(%{}, [String.t()]) :: %{score: non_neg_integer()}
    defp multiply_keywords(%{tags: tags} = video, keywords) do
      score =
        Enum.reduce(tags, 0, fn %{name: name, weight: weight}, acc ->
          multiplier = if name in keywords, do: @keyword_multiplier, else: 1

          weight * multiplier + acc
        end)

      Map.put(video, :score, score)
    end
  end
end
