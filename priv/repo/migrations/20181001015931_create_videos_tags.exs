defmodule DocGen.Repo.Migrations.CreateVideosTags do
  use Ecto.Migration

  def change do
    create table(:videos_tags) do
      add(:video_id, references(:videos))
      add(:tag_id, references(:tags))
    end

    create unique_index(:videos_tags, [:video_id, :tag_id])
  end
end
