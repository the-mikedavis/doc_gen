defmodule DocGen.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add(:filename, :string)
      add(:content_type, :string)
      add(:path, :string)
      add(:weight, :integer)
      add(:title, :string)
      add(:duration, :integer)

      timestamps()
    end

    create(unique_index(:videos, [:title]))
  end
end
