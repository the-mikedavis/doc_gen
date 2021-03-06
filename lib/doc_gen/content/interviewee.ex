defmodule DocGen.Content.Interviewee do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc "Interviewee schema: who's getting interviewed in the clip"

  schema "interviewees" do
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(interviewee, attrs) do
    interviewee
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
