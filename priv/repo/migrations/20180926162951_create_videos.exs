defmodule DocGen.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add(:title, :string)
      add(:filename, :string)
      add(:path, :string)

      timestamps()
    end

    create(unique_index(:videos, [:filename]))
  end
end
