defmodule DocGen.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add(:filename, :string)
      add(:content_type, :string)
      add(:path, :string)
      add(:interviewee, :string)
      add(:weight, :integer)

      timestamps()
    end

    create(unique_index(:videos, [:filename]))
  end
end
