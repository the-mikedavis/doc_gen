defmodule DocGen.Accounts.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "The settings schema which keeps track of long-persisted state"

  schema "settings" do
    # title of the movie
    field(:title, :string)
    # length of the movie in number of clips
    field(:beginning_clips, :integer)
    field(:middle_clips, :integer)
    field(:end_clips, :integer)
    # intro copy visible from the main page
    field(:copy, :string)

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:title, :beginning_clips, :middle_clips, :end_clips, :copy])
    |> validate_required([:title, :beginning_clips, :middle_clips, :end_clips])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_inclusion(:beginning_clips, 0..100)
    |> validate_inclusion(:middle_clips, 0..100)
    |> validate_inclusion(:end_clips, 0..100)
  end
end
