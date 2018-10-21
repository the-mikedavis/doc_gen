defmodule DocGen.Accounts.Setting do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "The settings schema which keeps track of long-persisted state"

  schema "settings" do
    # title of the movie
    field(:title, :string)
    # length of the movie in number of clips
    field(:length, :integer)
    # intro copy visible from the main page
    field(:copy, :string)

    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:title, :length, :copy])
    |> validate_required([:title, :length])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_inclusion(:length, 1..100)
  end
end
