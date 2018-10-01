defmodule DocGen.Content.Random do
  @moduledoc """
  Gives random videos based on the weight and lengths of videos and tags.
  """

  alias DocGen.Content

  @chosen_multiplier Application.get_env(:doc_gen, :user_chosen_keyword_multiplier)

  def give(_tags, _length) do
    Content.list_videos()
  end

  # def give(tags, length) do
    # all_tags =
      # Content.list_tags_with_videos()
      # |> Enum.map(&Map.from_struct/1)
      # |> Enum.map(fn tag ->
        # if tag.name in tags do
          # Map.update!(tag, :weight, &(&1 * 5))
          # else
          # tag
          # end
        # end)

      # total_weight = Enum.reduce(tags, 0, fn tag, acc -> acc + tag.weight end)
      # end
end
